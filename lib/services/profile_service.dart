import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/app_database.dart';
import '../database/database_converters.dart';
import 'package:drift/drift.dart' as drift;

/// Service for managing user profile data with offline-first architecture
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppDatabase _database = AppDatabase();
  final Connectivity connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final results = await connectivity.checkConnectivity();
    return results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  /// Update user profile with offline support
  /// If offline, queues the update
  /// If online, updates Firebase directly
  Future<bool> updateProfile({
    String? name,
    String? about,
    List<String>? languages,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    final docId = (user.email ?? '').toLowerCase().isNotEmpty
        ? (user.email ?? '').toLowerCase()
        : user.uid;

    final isOnline = await hasConnectivity();
    final Map<String, dynamic> updates = {};

    if (name != null) updates['displayName'] = name;
    if (about != null) updates['about'] = about;
    if (languages != null) updates['languages'] = languages;
    updates['updatedAt'] = isOnline
        ? FieldValue.serverTimestamp()
        : DateTime.now().toIso8601String();

    if (isOnline) {
      try {
        // Update Firebase
        await _firestore.collection('users').doc(docId).update(updates);
        print('✓ Profile updated online');

        // Update local database
        await _updateLocalDatabase(docId, updates);
        return true;
      } catch (e) {
        print('❌ Failed to update profile online: $e');
        // Fall through to offline update
      }
    }

    // Update local database with dirty flag
    await _updateLocalDatabase(docId, updates, markDirty: true);
    print('📥 Profile update queued for later sync (offline)');
    return false; // Return false to indicate offline save
  }

  /// Update local database with profile changes
  Future<void> _updateLocalDatabase(
    String docId,
    Map<String, dynamic> updates, {
    bool markDirty = false,
  }) async {
    try {
      // First, try to get the existing user to merge updates
      final existingUser = await _database.getUserById(docId);

      if (existingUser != null) {
        // Update existing user - only update changed fields
        await _database.updateUserFields(
          docId,
          name: updates.containsKey('displayName')
              ? updates['displayName'] as String
              : null,
          about:
              updates.containsKey('about') ? updates['about'] as String : null,
          languages: updates.containsKey('languages')
              ? '[${(updates['languages'] as List<String>).map((e) => '"$e"').join(', ')}]'
              : null,
          isDirty: markDirty,
        );
        print('✓ Profile updated in local database');
      } else {
        // User doesn't exist locally yet - fetch from Firebase and insert
        print('⚠️ User not in local DB, fetching from Firebase...');
        final docSnapshot =
            await _firestore.collection('users').doc(docId).get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;

          // Apply the updates to the fetched data
          if (updates.containsKey('displayName')) {
            data['displayName'] = updates['displayName'];
          }
          if (updates.containsKey('about')) {
            data['about'] = updates['about'];
          }
          if (updates.containsKey('languages')) {
            data['languages'] = updates['languages'];
          }

          // Create complete user record
          await _database.upsertUser(
            UsersCompanion(
              id: drift.Value(docId),
              name: drift.Value(data['displayName'] ?? data['name'] ?? 'User'),
              email: drift.Value(data['email'] ?? ''),
              avgHostRating: drift.Value(
                  (data['avgHostRating'] as num?)?.toDouble() ?? 0.0),
              isVerified: drift.Value(data['isVerified'] == true),
              memberSince: drift.Value(
                data['createdAt'] is Timestamp
                    ? (data['createdAt'] as Timestamp).toDate()
                    : DateTime.now(),
              ),
              languages: drift.Value(
                updates.containsKey('languages')
                    ? '[${(updates['languages'] as List<String>).map((e) => '"$e"').join(', ')}]'
                    : (data['languages'] is List
                        ? '[${(data['languages'] as List).map((e) => '"$e"').join(', ')}]'
                        : '[]'),
              ),
              responseRate: drift.Value(data['responseRate'] ?? 'N/A'),
              about: drift.Value(
                updates.containsKey('about')
                    ? updates['about'] as String
                    : (data['about'] ?? 'Tell others about yourself.'),
              ),
              hostedExperiences: drift.Value(data['hostedExperiences'] ?? 0),
              joinedExperiences: drift.Value(data['joinedExperiences'] ?? 0),
              photoURL: drift.Value(data['photoURL'] as String?),
              isDirty: drift.Value(markDirty),
              lastSyncedAt: drift.Value(DateTime.now()),
            ),
          );
          print('✓ Profile created in local database');
        }
      }
    } catch (e) {
      print('❌ Failed to update local database: $e');
      rethrow;
    }
  }

  /// Start monitoring connectivity and auto-sync when online
  void startConnectivityMonitoring() {
    if (_connectivitySubscription != null) return; // Already monitoring

    // Check for pending changes on startup
    _checkAndSyncOnStartup();

    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isConnected = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);

        if (isConnected) {
          await _firestore.enableNetwork();
          if (!_isSyncing) {
            print('🌐 Connectivity restored, syncing profile changes...');
            syncPendingChanges();
          }
        } else {
          await _firestore.disableNetwork();
        }
      },
    );
  }

  /// Check and sync pending changes on app startup if online
  Future<void> _checkAndSyncOnStartup() async {
    final isOnline = await hasConnectivity();
    if (isOnline) {
      await _firestore.enableNetwork();
      if (!_isSyncing) {
        print('📱 App started online, checking for pending profile changes...');
        await syncPendingChanges();
      }
    } else {
      await _firestore.disableNetwork();
    }
  }

  /// Sync pending profile changes to Firebase
  Future<void> syncPendingChanges() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    try {
      print('🔄 Starting profile sync...');

      // Get dirty users (those with pending changes)
      final dirtyUsers = await _database.getDirtyUsers();

      if (dirtyUsers.isEmpty) {
        print('✓ No pending profile changes to sync');
        return;
      }

      print('📦 Found ${dirtyUsers.length} profile(s) with pending changes');

      for (final driftUser in dirtyUsers) {
        try {
          final host = DatabaseConverters.hostFromDrift(driftUser);

          // Prepare update data
          final Map<String, dynamic> updates = {
            'displayName': host.name,
            'about': host.about,
            'languages': host.languages,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          // Update Firebase
          await _firestore.collection('users').doc(host.id).update(updates);

          // Mark as synced in local database
          await _database.markUserSynced(host.id);

          print('✓ Synced profile for user ${host.id}');
        } catch (e) {
          print('❌ Failed to sync profile ${driftUser.id}: $e');
          // Continue with next user
        }
      }

      print('✅ Profile sync complete');
    } finally {
      _isSyncing = false;
    }
  }

  /// Stop connectivity monitoring
  void stopConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Get experience counts for a user (hosted and joined)
  /// Returns a map with 'hosted' and 'joined' counts
  Future<Map<String, int>> getExperienceCounts(String userId) async {
    try {
      final isOnline = await hasConnectivity();

      if (isOnline) {
        // Count hosted experiences (where hostId matches userId)
        final hostedSnapshot = await _firestore
            .collection('experiences')
            .where('hostId', isEqualTo: userId)
            .get();

        // Count joined experiences (would need to check bookings collection)
        // For now, checking if user has any bookings
        final joinedSnapshot = await _firestore
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'confirmed')
            .get();

        // Get unique experience IDs from bookings
        final joinedExperienceIds =
            joinedSnapshot.docs.map((doc) => doc['experienceId']).toSet();

        return {
          'hosted': hostedSnapshot.docs.length,
          'joined': joinedExperienceIds.length,
        };
      } else {
        // Fallback to local database when offline
        final hostedCount = await _database.getHostedExperiencesCount(userId);
        final joinedCount = await _database.getJoinedExperiencesCount(userId);

        return {
          'hosted': hostedCount,
          'joined': joinedCount,
        };
      }
    } catch (e) {
      print('❌ Failed to get experience counts: $e');
      return {'hosted': 0, 'joined': 0};
    }
  }

  /// Dispose resources
  void dispose() {
    stopConnectivityMonitoring();
  }
}
