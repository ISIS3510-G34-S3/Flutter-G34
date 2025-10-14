import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travel_connect/models/experience.dart';

class ExperienceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Experience>> getExperiences() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('experiences').get();
      return snapshot.docs.map((doc) => Experience.fromFirestore(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Experience?> getExperienceById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('experiences').doc(id).get();
      if (doc.exists) {
        return Experience.fromFirestore(doc);
      }
    } catch (e) {
      print(e);
    }
    return null;
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

    final data = docSnap.data() as Map<String, dynamic>?;
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
