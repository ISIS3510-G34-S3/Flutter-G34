import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/host.dart';
import '../database/app_database.dart';
import '../database/database_converters.dart';

class HostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppDatabase _database = AppDatabase();

  /// Get host/user by ID with offline-first strategy
  Future<Host?> getHostById(String id) async {
    Host? host;

    // STEP 1: Try Firebase cache
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(id)
          .get(const GetOptions(source: Source.cache));
      if (doc.exists) {
        host = Host.fromFirestore(doc);
        print('✓ Got host $id from Firebase cache');
        return host;
      }
    } catch (e) {
      print('Could not get host $id from cache: $e');
    }

    // STEP 2: Try local database
    try {
      final localUser = await _database.getUserById(id);
      if (localUser != null) {
        host = DatabaseConverters.hostFromDrift(localUser);
        print('✓ Got host $id from local database');
        return host;
      }
    } catch (e) {
      print('Could not get host $id from local DB: $e');
    }

    // STEP 3: Try Firebase server
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        host = Host.fromFirestore(doc);
        print('✓ Got host $id from Firebase server');

        // Update local database
        await _database.upsertUser(
          DatabaseConverters.hostToCompanion(host),
        );

        return host;
      }
    } catch (e) {
      print('Error getting host from server: $e');
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
