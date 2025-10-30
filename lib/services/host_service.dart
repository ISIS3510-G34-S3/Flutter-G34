import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/host.dart';

class HostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Host?> getHostById(String id) async {
    Host? host;
    // 1. Try cache first
    try {
      final doc = await _firestore
          .collection('users')
          .doc(id)
          .get(const GetOptions(source: Source.cache));
      if (doc.exists) {
        host = Host.fromFirestore(doc);
      }
    } catch (e) {
      print('Could not get host $id from cache: $e');
    }

    // 2. Check for internet connection
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Returning cached host for $id.');
      return host;
    }

    // 3. If connected, try server
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        host = Host.fromFirestore(doc);
      }
    } catch (e) {
      print('Could not fetch host $id from server: $e');
    }
    return host;
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
