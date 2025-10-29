import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/host.dart';

class HostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Host?> getHostById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return Host.fromFirestore(doc);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Host?> getCurrentUserHost() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final docId = (user.email ?? '').toLowerCase().isNotEmpty
        ? (user.email ?? '').toLowerCase()
        : user.uid;
    
    return getHostById(docId);
  }
}
