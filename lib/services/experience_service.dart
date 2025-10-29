import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travel_connect/models/experience.dart';

class ExperienceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Experience>> getExperiences({bool forceRefresh = false}) async {
    List<Experience> experiences = [];

    // 1. Get from cache first, if not forcing a refresh.
    if (!forceRefresh) {
      try {
        final cacheSnapshot = await _firestore
            .collection('experiences')
            .get(const GetOptions(source: Source.cache));
        if (cacheSnapshot.docs.isNotEmpty) {
          experiences = cacheSnapshot.docs
              .map((doc) => Experience.fromFirestore(doc))
              .toList();
        }
      } catch (e) {
        print('Could not fetch from cache: $e');
      }
    }

    // 2. Check for internet connection.
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Returning cached experiences.');
      return experiences;
    }

    // 3. If connected, try to get from server.
    try {
      final serverSnapshot = await _firestore.collection('experiences').get();
      if (serverSnapshot.docs.isNotEmpty) {
        experiences = serverSnapshot.docs
            .map((doc) => Experience.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      print('Could not fetch from server: $e');
    }

    return experiences;
  }

  Future<Experience?> getExperienceById(String id) async {
    Experience? experience;
    // 1. Try cache first
    try {
      final doc = await _firestore
          .collection('experiences')
          .doc(id)
          .get(const GetOptions(source: Source.cache));
      if (doc.exists) {
        experience = Experience.fromFirestore(doc);
      }
    } catch (e) {
      print('Could not get experience $id from cache: $e');
    }

    // 2. Check for internet connection
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Returning cached experience for $id.');
      return experience;
    }

    // 3. If connected, try server
    try {
      DocumentSnapshot doc =
          await _firestore.collection('experiences').doc(id).get();
      if (doc.exists) {
        experience = Experience.fromFirestore(doc);
      }
    } catch (e) {
      print('Could not fetch experience $id from server: $e');
    }
    return experience;
  }

  /// Stream the current user's experiences using the same host reference rule
  /// used when creating an experience (email lowercase if present, else uid).
  Stream<List<Experience>> watchMyExperiences() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return empty stream if not authenticated
      return const Stream<List<Experience>>.empty();
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
            .map((doc) => Experience.fromFirestore(doc))
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
