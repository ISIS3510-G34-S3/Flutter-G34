import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travel_connect/models/experience.dart' as models;
import 'package:travel_connect/database/app_database.dart';
import 'package:travel_connect/database/database_converters.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:io';
import 'pending_operations_service.dart';

class ExperienceService {
  ExperienceService._internal();
  static final ExperienceService _instance = ExperienceService._internal();

  factory ExperienceService() {
    _instance.startConnectivityMonitoring();
    return _instance;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppDatabase _database = AppDatabase();
  final PendingOperationsService _pendingOps = PendingOperationsService();
  final Connectivity connectivity = Connectivity(); // Made public for listening
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  final Set<String> _hostMetadataEnsured = <String>{};

  /// Get experiences with offline-first strategy:
  /// 1. Try Firebase Cache (in-memory, fastest)
  /// 2. Fall back to Local SQLite Database (persistent, offline)
  /// 3. Try Firebase Server (network, updates cache and DB)
  /// 4. Return what we have or empty list
  ///
  /// This strategy ensures the app works offline and minimizes battery drain
  /// by NOT polling Firebase periodically.
  ///
  /// When forceRefresh = true, fetches fresh data from server and updates all caches.
  Future<List<models.Experience>> getExperiences(
      {bool forceRefresh = false}) async {
    List<models.Experience> experiences = [];

    // If forceRefresh is true, skip cache/local and fetch directly from server
    // This mimics what happens when changing screens but forces a server fetch
    if (forceRefresh) {
      print('� Force refresh: Fetching directly from Firebase server...');

      // Skip STEP 1 (Firebase Cache) and STEP 2 (Local DB)
      // Go directly to STEP 3 (Firebase Server)
      try {
        print('📡 Fetching from Firebase server (bypass cache)...');
        final serverSnapshot = await _firestore
            .collection('experiences')
            .get(const GetOptions(source: Source.server));

        if (serverSnapshot.docs.isNotEmpty) {
          experiences = serverSnapshot.docs
              .map((doc) => models.Experience.fromFirestore(doc))
              .toList();
          print('✅ Loaded ${experiences.length} fresh experiences from server');

          // Update local database with fresh server data (don't clear, just update)
          await _syncServerToLocalDB(experiences);
          print('✅ Synced ${experiences.length} experiences to local database');
        } else {
          print('⚠️ No experiences found on server');
        }
        return experiences;
      } catch (e) {
        print('❌ Firebase server error during force refresh: $e');
        // Fall back to local database if server fails
        try {
          final localExperiences = await _database.getAllExperiences();
          if (localExperiences.isNotEmpty) {
            experiences = localExperiences
                .map((e) => DatabaseConverters.experienceFromDrift(e))
                .toList();
            print(
                '✓ Loaded ${experiences.length} experiences from local database (fallback)');
          }
        } catch (localError) {
          print('❌ Local database error: $localError');
        }
        return experiences;
      }
    }

    // STEP 1: Try Firebase Cache first (fastest, in-memory)
    try {
      final cacheSnapshot = await _firestore
          .collection('experiences')
          .get(const GetOptions(source: Source.cache));
      if (cacheSnapshot.docs.isNotEmpty) {
        experiences = cacheSnapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList();
        print('✓ Loaded ${experiences.length} experiences from Firebase cache');

        // Cache hit - also ensure local DB is synced in background
        _syncCacheToLocalDB(experiences);

        return experiences;
      }
    } catch (e) {
      print('Firebase cache miss or error: $e');
    }

    // STEP 2: Try Local SQLite Database (offline persistence)
    try {
      final localExperiences = await _database.getAllExperiences();
      if (localExperiences.isNotEmpty) {
        experiences = localExperiences
            .map((e) => DatabaseConverters.experienceFromDrift(e))
            .toList();
        print('✓ Loaded ${experiences.length} experiences from local database');

        // We have local data - try to refresh from server in background
        _refreshFromServerInBackground();

        // Return local data immediately
        return experiences;
      }
    } catch (e) {
      print('Local database error: $e');
    }

    // STEP 3: Try Firebase Server (requires network)
    try {
      final serverSnapshot = await _firestore.collection('experiences').get();
      if (serverSnapshot.docs.isNotEmpty) {
        experiences = serverSnapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList();
        print(
            '✓ Loaded ${experiences.length} experiences from Firebase server');

        // Update local database with server data
        await _syncServerToLocalDB(experiences);
      }
    } catch (e) {
      print('Firebase server error: $e');
      // If we already have local data, return it even if server fails
      if (experiences.isNotEmpty) {
        return experiences;
      }
    }

    return experiences;
  }

  /// Sync Firebase cache data to local database in background
  Future<void> _syncCacheToLocalDB(List<models.Experience> experiences) async {
    try {
      final companions = experiences
          .map((e) => DatabaseConverters.experienceToCompanion(e))
          .toList();
      await _database.upsertExperiences(companions);
      print('✓ Synced ${experiences.length} experiences to local database');
    } catch (e) {
      print('Error syncing cache to local DB: $e');
    }
  }

  /// Sync Firebase server data to local database
  Future<void> _syncServerToLocalDB(List<models.Experience> experiences) async {
    try {
      final companions = experiences
          .map((e) => DatabaseConverters.experienceToCompanion(e))
          .toList();
      await _database.upsertExperiences(companions);
      print(
          '✓ Synced ${experiences.length} experiences from server to local database');
    } catch (e) {
      print('Error syncing server to local DB: $e');
    }
  }

  /// Refresh from server in background without blocking UI
  void _refreshFromServerInBackground() {
    // Fire and forget - don't await, don't block
    _firestore.collection('experiences').get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final experiences = snapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList();
        _syncServerToLocalDB(experiences);
      }
    }).catchError((e) {
      print('Background refresh failed: $e');
    });
  }

  /// Get experiences by host ID with offline-first strategy
  /// When forceRefresh = true, fetches fresh data directly from server.
  Future<List<models.Experience>> getExperiencesByHost(String hostId,
      {bool forceRefresh = false}) async {
    List<models.Experience> experiences = [];

    // If forceRefresh is true, fetch fresh from server
    if (forceRefresh) {
      try {
        print(
            '🔄 Force refresh: fetching host $hostId experiences from Firebase server...');

        // Fetch directly from server (bypassing Firestore cache)
        final serverSnapshot = await _firestore
            .collection('experiences')
            .where('hostId',
                isEqualTo: _firestore.collection('users').doc(hostId))
            .get(const GetOptions(source: Source.server));
        if (serverSnapshot.docs.isNotEmpty) {
          experiences = serverSnapshot.docs
              .map((doc) => models.Experience.fromFirestore(doc))
              .toList();
          print(
              '✓ Loaded ${experiences.length} fresh experiences for host $hostId from Firebase server');

          // Update local database with fresh server data
          await _syncServerToLocalDB(experiences);
          print('✓ Updated local database with host experiences');
        } else {
          print('⚠️ No experiences found for host $hostId on server');
        }
        return experiences;
      } catch (e) {
        print(
            '❌ Firebase server error during force refresh for host $hostId: $e');
        // If server fails during force refresh, fall back to local/cache data
        try {
          // Try Firebase cache first
          final cacheSnapshot = await _firestore
              .collection('experiences')
              .where('hostId',
                  isEqualTo: _firestore.collection('users').doc(hostId))
              .get(const GetOptions(source: Source.cache));
          if (cacheSnapshot.docs.isNotEmpty) {
            experiences = cacheSnapshot.docs
                .map((doc) => models.Experience.fromFirestore(doc))
                .toList();
            print(
                '✓ Loaded ${experiences.length} experiences for host $hostId from cache (fallback)');
            return experiences;
          }

          // Fall back to local database
          final allLocalExperiences = await _database.getAllExperiences();
          if (allLocalExperiences.isNotEmpty) {
            final hostExperiences = allLocalExperiences
                .where((exp) => exp.hostId == hostId)
                .map((e) => DatabaseConverters.experienceFromDrift(e))
                .toList();

            if (hostExperiences.isNotEmpty) {
              experiences = hostExperiences;
              print(
                  '✓ Loaded ${experiences.length} experiences for host $hostId from local database (fallback)');
            }
          }
        } catch (fallbackError) {
          print('❌ Fallback also failed for host $hostId: $fallbackError');
        }
        return experiences;
      }
    }

    // STEP 1: Try Firebase Cache first (fastest, in-memory)
    try {
      final cacheSnapshot = await _firestore
          .collection('experiences')
          .where('hostId',
              isEqualTo: _firestore.collection('users').doc(hostId))
          .get(const GetOptions(source: Source.cache));
      if (cacheSnapshot.docs.isNotEmpty) {
        experiences = cacheSnapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList();
        print(
            '✓ Loaded ${experiences.length} experiences for host $hostId from Firebase cache');

        // Cache hit - also ensure local DB is synced in background
        _syncCacheToLocalDB(experiences);
        return experiences;
      }
    } catch (e) {
      print('Firebase cache miss or error for host $hostId: $e');
    }

    // STEP 2: Try Local SQLite Database (offline persistence)
    try {
      final allLocalExperiences = await _database.getAllExperiences();
      if (allLocalExperiences.isNotEmpty) {
        // Filter by hostId
        final hostExperiences = allLocalExperiences
            .where((exp) => exp.hostId == hostId)
            .map((e) => DatabaseConverters.experienceFromDrift(e))
            .toList();

        if (hostExperiences.isNotEmpty) {
          experiences = hostExperiences;
          print(
              '✓ Loaded ${experiences.length} experiences for host $hostId from local database');

          // We have local data - try to refresh from server in background
          _refreshHostExperiencesInBackground(hostId);

          // Return local data immediately
          return experiences;
        }
      }
    } catch (e) {
      print('Local database error for host $hostId: $e');
    }

    // STEP 3: Try Firebase Server (requires network)
    try {
      final serverSnapshot = await _firestore
          .collection('experiences')
          .where('hostId',
              isEqualTo: _firestore.collection('users').doc(hostId))
          .get();
      if (serverSnapshot.docs.isNotEmpty) {
        experiences = serverSnapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList();
        print(
            '✓ Loaded ${experiences.length} experiences for host $hostId from Firebase server');

        // Update local database with server data
        await _syncServerToLocalDB(experiences);
      }
    } catch (e) {
      print('Firebase server error for host $hostId: $e');
      // If we already have local data, return it even if server fails
      if (experiences.isNotEmpty) {
        return experiences;
      }
    }

    return experiences;
  }

  /// Refresh host experiences from server in background without blocking UI
  void _refreshHostExperiencesInBackground(String hostId) {
    // Fire and forget - don't await, don't block
    _firestore
        .collection('experiences')
        .where('hostId', isEqualTo: _firestore.collection('users').doc(hostId))
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final experiences = snapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList();
        _syncServerToLocalDB(experiences);
      }
    }).catchError((e) {
      print('Background refresh failed for host $hostId: $e');
    });
  }

  Future<models.Experience?> getExperienceById(String id) async {
    models.Experience? experience;

    // STEP 1: Try Firebase cache
    try {
      final doc = await _firestore
          .collection('experiences')
          .doc(id)
          .get(const GetOptions(source: Source.cache));
      if (doc.exists) {
        experience = models.Experience.fromFirestore(doc);
        print('✓ Got experience $id from Firebase cache');
        return experience;
      }
    } catch (e) {
      print('Could not get experience $id from cache: $e');
    }

    // STEP 2: Try local database
    try {
      final localExp = await _database.getExperienceById(id);
      if (localExp != null) {
        experience = DatabaseConverters.experienceFromDrift(localExp);
        print('✓ Got experience $id from local database');
        return experience;
      }
    } catch (e) {
      print('Could not get experience $id from local DB: $e');
    }

    // STEP 3: Try Firebase server
    try {
      DocumentSnapshot doc =
          await _firestore.collection('experiences').doc(id).get();
      if (doc.exists) {
        experience = models.Experience.fromFirestore(doc);
        print('✓ Got experience $id from Firebase server');

        // Update local database
        await _database.upsertExperience(
          DatabaseConverters.experienceToCompanion(experience),
        );

        return experience;
      }
    } catch (e) {
      print('Error getting experience from server: $e');
    }

    return null;
  }

  /// Stream the current user's experiences using the same host reference rule
  /// used when creating an experience (email lowercase if present, else uid).
  Stream<List<models.Experience>> watchMyExperiences() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return empty stream if not authenticated
      return const Stream<List<models.Experience>>.empty();
    }

    final String hostDocId = (user.email ?? '').toLowerCase().isNotEmpty
        ? (user.email ?? '').toLowerCase()
        : user.uid;
    final DocumentReference hostRef =
        _firestore.collection('users').doc(hostDocId);

    if (!_hostMetadataEnsured.contains(hostDocId)) {
      _hostMetadataEnsured.add(hostDocId);
      unawaited(_ensureHostMetadata(hostDocId, hostRef));
    }

    return _firestore
        .collection('experiences')
        .where('hostDocId', isEqualTo: hostDocId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList());
  }

  Future<void> _ensureHostMetadata(
      String hostDocId, DocumentReference hostRef) async {
    if (!await hasConnectivity()) return;

    try {
      final stringSnapshot = await _firestore
          .collection('experiences')
          .where('hostId', isEqualTo: hostDocId)
          .get();

      for (final doc in stringSnapshot.docs) {
        await doc.reference.update({
          'hostId': hostRef,
          'hostDocId': hostDocId,
        });
      }

      final refSnapshot = await _firestore
          .collection('experiences')
          .where('hostId', isEqualTo: hostRef)
          .get();

      for (final doc in refSnapshot.docs) {
        if (!(doc.data().containsKey('hostDocId'))) {
          await doc.reference.update({'hostDocId': hostDocId});
        }
      }
    } catch (e) {
      print('⚠️ Failed to ensure host metadata for $hostDocId: $e');
    }
  }

  /// Update an experience document by id. Automatically updates updatedAt.
  Future<void> updateExperience(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('experiences').doc(id).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an experience and all associated images (offline-capable)
  Future<bool> deleteExperienceAndImages(String id,
      {List<String> imageUrls = const []}) async {
    return deleteExperienceOfflineCapable(id, imageUrls: imageUrls);
  }

  Future<bool> deleteExperienceOfflineCapable(String id,
      {List<String> imageUrls = const []}) async {
    final isOnline = await hasConnectivity();

    if (isOnline) {
      try {
        await _deleteExperienceAndImagesOnline(id, imageUrls: imageUrls);
        print('✓ Experience deleted online: $id');
        return true;
      } catch (e) {
        print('❌ Failed to delete experience online: $e');
        // Fall through to offline queue
      }
    }

    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    await _pendingOps.addPendingOperation(
      PendingOperation(
        id: operationId,
        type: 'delete',
        experienceId: id,
        data: {
          'images': imageUrls,
        },
        timestamp: DateTime.now(),
      ),
    );
    print('📥 Experience deletion queued for later sync (offline)');
    return false;
  }

  Future<void> _deleteExperienceAndImagesOnline(String id,
      {List<String> imageUrls = const []}) async {
    List<String> images = List<String>.from(imageUrls);

    if (images.isEmpty) {
      final docSnap = await _firestore.collection('experiences').doc(id).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        images = (data?['images'] as List?)?.cast<String>() ?? const [];
      }
    }

    // Use the same bucket used in creation
    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://travelappbd-8e204.firebasestorage.app',
    );

    // Best-effort delete each image; continue even if one fails
    for (final url in images) {
      try {
        if (url.isNotEmpty) {
          final ref = storage.refFromURL(url);
          await ref.delete();
        }
      } catch (_) {
        // ignore individual image deletion failures
      }
    }

    await _firestore.collection('experiences').doc(id).delete();
  }

  /// Start monitoring connectivity and auto-sync when online
  void startConnectivityMonitoring() {
    if (_connectivitySubscription != null) return; // Already monitoring

    // Check for pending operations on startup
    _checkAndSyncOnStartup();

    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isConnected = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);

        if (isConnected) {
          await _firestore.enableNetwork();
          if (!_isSyncing) {
            print('🌐 Connectivity restored, syncing pending operations...');
            syncPendingOperations();
          }
        } else {
          await _firestore.disableNetwork();
        }
      },
    );
  }

  /// Check and sync pending operations on app startup if online
  Future<void> _checkAndSyncOnStartup() async {
    final isOnline = await hasConnectivity();
    if (isOnline) {
      await _firestore.enableNetwork();
      if (!_isSyncing) {
        print('📱 App started online, checking for pending operations...');
        await syncPendingOperations();
      }
    } else {
      await _firestore.disableNetwork();
    }
  }

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final results = await connectivity.checkConnectivity();
    return results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  /// Create an experience with offline support
  /// If offline, queues the operation and saves locally
  /// If online, saves to Firebase directly
  Future<String?> createExperienceOfflineCapable(
      Map<String, dynamic> experienceData, List<String> localImagePaths) async {
    final isOnline = await hasConnectivity();

    if (isOnline) {
      try {
        final Map<String, dynamic> onlineData =
            Map<String, dynamic>.from(experienceData);

        final hostIdValue = onlineData['hostId'];
        if (hostIdValue is String && hostIdValue.isNotEmpty) {
          final hostRef = _firestore.collection('users').doc(hostIdValue);
          onlineData['hostId'] = hostRef;
          onlineData['hostDocId'] ??= hostIdValue;
        }

        final locationValue = onlineData['location'];
        if (locationValue is Map) {
          final latitude = (locationValue['latitude'] ?? locationValue['lat']);
          final longitude =
              (locationValue['longitude'] ?? locationValue['lng']);
          if (latitude is num && longitude is num) {
            onlineData['location'] = GeoPoint(
              latitude.toDouble(),
              longitude.toDouble(),
            );
          }
        }

        onlineData['createdAt'] = FieldValue.serverTimestamp();
        onlineData['updatedAt'] = FieldValue.serverTimestamp();

        final docRef =
            await _firestore.collection('experiences').add(onlineData);
        print('✓ Experience created online: ${docRef.id}');
        return docRef.id;
      } catch (e) {
        print('❌ Failed to create experience online: $e');
      }
    }

    // Queue for later sync
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    await _pendingOps.addPendingOperation(
      PendingOperation(
        id: operationId,
        type: 'create',
        data: experienceData,
        timestamp: DateTime.now(),
        localImagePaths: localImagePaths,
      ),
    );
    print('📥 Experience queued for later sync (offline) with ${localImagePaths.length} images');
    return null; // Return null to indicate offline save
  }

  /// Update an experience with offline support
  /// If offline, queues the operation
  /// If online, updates Firebase directly
  Future<bool> updateExperienceOfflineCapable(
      String id, Map<String, dynamic> updates) async {
    final isOnline = await hasConnectivity();

    // Prepare data copies so original map isn't mutated
    final Map<String, dynamic> onlineUpdates = Map<String, dynamic>.from(updates);
    final Map<String, dynamic> offlineUpdates = Map<String, dynamic>.from(updates);

    // Normalize location for online update if needed
    if (onlineUpdates['location'] is Map) {
      final locMap = onlineUpdates['location'] as Map;
      onlineUpdates['location'] = GeoPoint(
        (locMap['latitude'] as num).toDouble(),
        (locMap['longitude'] as num).toDouble(),
      );
    }

    if (isOnline) {
      try {
        // Try to update directly on Firebase
        await updateExperience(id, onlineUpdates);
        print('✓ Experience updated online: $id');
        return true;
      } catch (e) {
        print('❌ Failed to update experience online: $e');
        // Fall through to offline queue
      }
    }

    // Normalize for offline storage: convert GeoPoint to map & timestamps to ISO
    if (offlineUpdates['location'] is GeoPoint) {
      final loc = offlineUpdates['location'] as GeoPoint;
      offlineUpdates['location'] = {
        'latitude': loc.latitude,
        'longitude': loc.longitude,
      };
    }
    offlineUpdates['updatedAt'] = DateTime.now().toIso8601String();

    // Queue for later sync
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    await _pendingOps.addPendingOperation(
      PendingOperation(
        id: operationId,
        type: 'update',
        data: offlineUpdates,
        experienceId: id,
        timestamp: DateTime.now(),
      ),
    );
    print('📥 Experience update queued for later sync (offline)');
    return false; // Return false to indicate offline save
  }

  /// Sync all pending operations to Firebase
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _pendingOps.getPendingOperations();
      if (pending.isEmpty) {
        print('✓ No pending operations to sync');
        _isSyncing = false;
        return;
      }

      print('🔄 Syncing ${pending.length} pending operations...');

      for (final operation in pending) {
        try {
          // Upload any pending local images first
          List<String> uploadedUrls = [];
          if (operation.localImagePaths.isNotEmpty) {
            print('📤 Uploading ${operation.localImagePaths.length} pending images...');
            uploadedUrls = await _uploadLocalImages(operation.localImagePaths);
            print('✓ Uploaded ${uploadedUrls.length} images');
          }

          if (operation.type == 'create') {
            // Merge uploaded URLs with any existing URLs in the data
            final existingImages = (operation.data['images'] as List?)?.cast<String>() ?? [];
            final allImages = [...existingImages, ...uploadedUrls];
            final updatedData = Map<String, dynamic>.from(operation.data);
            updatedData['images'] = allImages;

            // Convert hostId string to DocumentReference
            if (updatedData['hostId'] is String) {
              updatedData['hostId'] = _firestore
                  .collection('users')
                  .doc(updatedData['hostId'] as String);
            }

            // Convert location map to GeoPoint
            if (updatedData['location'] is Map) {
              final locMap = updatedData['location'] as Map;
              updatedData['location'] = GeoPoint(
                (locMap['latitude'] as num).toDouble(),
                (locMap['longitude'] as num).toDouble(),
              );
            }

            // Replace timestamp strings with FieldValue.serverTimestamp()
            updatedData['createdAt'] = FieldValue.serverTimestamp();
            updatedData['updatedAt'] = FieldValue.serverTimestamp();

            // Create the experience with all image URLs
            await _firestore.collection('experiences').add(updatedData);
            print('✓ Synced pending create operation: ${operation.id}');
          } else if (operation.type == 'update') {
            // Update the experience
            if (operation.experienceId != null) {
              final updatedData = Map<String, dynamic>.from(operation.data);
              
              // Merge uploaded URLs with existing if there are any
              if (uploadedUrls.isNotEmpty) {
                final existingImages = (operation.data['images'] as List?)?.cast<String>() ?? [];
                updatedData['images'] = [...existingImages, ...uploadedUrls];
              }

              // Convert location map to GeoPoint if necessary
              if (updatedData['location'] is Map) {
                final locMap = updatedData['location'] as Map;
                updatedData['location'] = GeoPoint(
                  (locMap['latitude'] as num).toDouble(),
                  (locMap['longitude'] as num).toDouble(),
                );
              }

              // Remove offline timestamps; will be set to server timestamp below
              updatedData.remove('updatedAt');

              await _firestore
                  .collection('experiences')
                  .doc(operation.experienceId)
                  .update({
                ...updatedData,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              print('✓ Synced pending update operation: ${operation.id}');
            }
          } else if (operation.type == 'delete') {
            if (operation.experienceId != null) {
              final images = (operation.data['images'] as List?)?.cast<String>() ?? const [];
              await _deleteExperienceAndImagesOnline(operation.experienceId!,
                  imageUrls: images);
              print('✓ Synced pending delete operation: ${operation.id}');
            }
          }

          // Remove from pending queue after successful sync
          await _pendingOps.removePendingOperation(operation.id);
        } catch (e) {
          print('❌ Failed to sync operation ${operation.id}: $e');
          // Continue with next operation
        }
      }

      print('✅ Sync complete');
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload local images to Firebase Storage
  /// Returns list of download URLs
  Future<List<String>> _uploadLocalImages(List<String> localPaths) async {
    final List<String> downloadUrls = [];
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No authenticated user for image upload');
      return downloadUrls;
    }

    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://travelappbd-8e204.firebasestorage.app',
    );

    for (final localPath in localPaths) {
      try {
        final file = File(localPath);
        if (!await file.exists()) {
          print('⚠️ Local image not found: $localPath');
          continue;
        }

        final String uid = user.uid;
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = localPath.split('.').last;
        final String fileName = 'photo_$timestamp.$extension';

        final bytes = await file.readAsBytes();
        final ref = storage.ref().child('experiences/$uid/$fileName');
        final uploadTask = await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final String downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        print('✓ Uploaded: $fileName');
      } catch (e) {
        print('❌ Failed to upload image $localPath: $e');
        // Continue with next image
      }
    }

    return downloadUrls;
  }
}
