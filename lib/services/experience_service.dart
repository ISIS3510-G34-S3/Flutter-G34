import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travel_connect/models/experience.dart' as models;
import 'package:travel_connect/database/app_database.dart';
import 'package:travel_connect/database/database_converters.dart';

class ExperienceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppDatabase _database = AppDatabase();

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

    return _firestore
        .collection('experiences')
        .where('hostId', isEqualTo: hostRef)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.Experience.fromFirestore(doc))
            .toList());
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

  /// Delete an experience and all associated images from Firebase Storage.
  Future<void> deleteExperienceAndImages(String id) async {
    final docRef = _firestore.collection('experiences').doc(id);
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      await docRef.delete();
      return;
    }

    final data = docSnap.data();
    final List images = (data?['images'] as List?) ?? const [];

    // Use the same bucket used in creation
    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://travelappbd-8e204.firebasestorage.app',
    );

    // Best-effort delete each image; continue even if one fails
    for (final dynamic url in images) {
      try {
        if (url is String && url.isNotEmpty) {
          final ref = storage.refFromURL(url);
          await ref.delete();
        }
      } catch (_) {
        // ignore individual image deletion failures
      }
    }

    // Finally delete the document
    await docRef.delete();
  }
}
