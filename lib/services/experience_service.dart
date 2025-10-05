import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_connect/models/experience.dart';

class ExperienceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
