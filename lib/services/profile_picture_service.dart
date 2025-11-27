import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'image_processing_service.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

/// Service for managing user profile pictures with offline support
class ProfilePictureService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://travelappbd-8e204.firebasestorage.app',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppDatabase _database = AppDatabase();
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  /// Pick and upload a profile picture from camera or gallery with offline support
  Future<String?> uploadProfilePicture({
    required ImageSource source,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print('📸 Starting profile picture upload for user: ${user.uid}');

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) {
        print('❌ User cancelled image selection');
        return null; // User cancelled
      }

      print('✓ Image picked, starting compression...');

      // Compress image using isolate
      final compressedBytes = await ImageProcessingService.compressImage(
        imagePath: pickedFile.path,
        maxWidth: 1024,
        quality: 85,
      );

      print('✓ Image compressed, size: ${compressedBytes.length} bytes');

      // Save to local storage in Travel Connect directory
      print('💾 Saving to local storage...');
      final localFile = await _saveToLocalStorage(compressedBytes, user.uid);
      final localPath = localFile.path;

      // Check connectivity
      final isOnline = await hasConnectivity();

      if (isOnline) {
        try {
          // Upload to Firebase Storage using userId (uid)
          print('☁️ Uploading to Firebase Storage...');
          final String downloadUrl = await _uploadToFirebaseStorage(
            compressedBytes,
            user.uid,
          );

          // Update Firestore
          print('📝 Updating Firestore...');
          await _updateFirestore(downloadUrl);

          // Update local database
          print('💾 Updating local database...');
          await _updateLocalDatabase(downloadUrl);

          print('✅ Profile picture upload completed successfully!');
          return downloadUrl;
        } catch (e) {
          if (e.toString().contains('unauthorized') ||
              e.toString().contains('permission')) {
            print(
                '❌ Firebase Storage permission denied. Please configure storage rules.');
            print('Add this rule to Firebase Storage:');
            print(
                'allow read, write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;');
          }
          print('⚠️ Failed to upload online, saving for later sync: $e');
          // Fall through to offline mode
        }
      }

      // Offline mode - save locally and mark as dirty
      print('📥 Saving profile picture offline (will sync when online)');
      await _updateLocalDatabase(localPath, markDirty: true);
      print('✓ Profile picture saved locally, queued for sync');
      return localPath; // Return local path when offline
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Save profile picture to local storage
  Future<File> _saveToLocalStorage(Uint8List imageBytes, String userId) async {
    Directory? picturesDir;

    if (Platform.isAndroid) {
      // On Android, use external storage Pictures directory
      final externalDirs =
          await getExternalStorageDirectories(type: StorageDirectory.pictures);
      if (externalDirs != null && externalDirs.isNotEmpty) {
        // Use public Pictures directory
        final basePath = externalDirs.first.path.split('/Android')[0];
        picturesDir = Directory('$basePath/Pictures/Travel Connect');
      }
    } else if (Platform.isIOS) {
      // On iOS, use app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      picturesDir = Directory('${appDir.path}/Travel Connect');
    } else {
      // Fallback for other platforms
      final appDir = await getApplicationDocumentsDirectory();
      picturesDir = Directory('${appDir.path}/Travel Connect');
    }

    if (picturesDir == null) {
      throw Exception('Could not find storage directory');
    }

    if (!await picturesDir.exists()) {
      await picturesDir.create(recursive: true);
    }

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'profile_$userId\_$timestamp.jpg';
    final localPath = '${picturesDir.path}/$fileName';
    final File localFile = File(localPath);

    await localFile.writeAsBytes(imageBytes);
    print('✓ Profile picture saved locally: $localPath');

    return localFile;
  }

  /// Upload profile picture to Firebase Storage
  /// Using 'profile_pic' folder in Firebase Storage
  Future<String> _uploadToFirebaseStorage(
    Uint8List imageBytes,
    String userId,
  ) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'profile_$timestamp.jpg';
    // Use profile_pic folder
    final ref = _storage.ref().child('profile_pic/$userId/$fileName');

    final uploadTask = await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final String downloadUrl = await uploadTask.ref.getDownloadURL();
    print('✓ Profile picture uploaded to Firebase: $downloadUrl');

    return downloadUrl;
  }

  /// Update Firestore with new profile picture URL
  Future<void> _updateFirestore(String photoURL) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docId = (user.email ?? '').toLowerCase().isNotEmpty
        ? (user.email ?? '').toLowerCase()
        : user.uid;

    await _firestore.collection('users').doc(docId).set(
      {
        'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    print('✓ Profile picture URL updated in Firestore');
  }

  /// Update local database with new profile picture URL
  Future<void> _updateLocalDatabase(String photoURL,
      {bool markDirty = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docId = (user.email ?? '').toLowerCase().isNotEmpty
        ? (user.email ?? '').toLowerCase()
        : user.uid;

    try {
      // Get existing user data
      final existingUser = await _database.getUserById(docId);

      if (existingUser != null) {
        // Update existing user's photoURL
        await _database.updateUserFields(
          docId,
          photoURL: photoURL,
          isDirty: markDirty,
        );
        print('✓ Profile picture URL updated in local database');
      } else {
        // User doesn't exist locally - try to fetch from Firestore
        print('⚠️ User not in local DB, attempting to fetch from Firestore...');
        try {
          final docSnapshot =
              await _firestore.collection('users').doc(docId).get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data()!;
            // Create complete user record with the new photo
            await _database.upsertUser(
              UsersCompanion(
                id: drift.Value(docId),
                name: drift.Value(data['displayName'] ??
                    data['name'] ??
                    user.displayName ??
                    'User'),
                email: drift.Value(data['email'] ?? user.email ?? ''),
                avgHostRating: drift.Value(
                    (data['avgHostRating'] as num?)?.toDouble() ?? 0.0),
                isVerified: drift.Value(data['isVerified'] == true),
                memberSince: drift.Value(
                  data['createdAt'] is Timestamp
                      ? (data['createdAt'] as Timestamp).toDate()
                      : DateTime.now(),
                ),
                languages: drift.Value(
                  data['languages'] is List
                      ? '[${(data['languages'] as List).map((e) => '"$e"').join(', ')}]'
                      : '[]',
                ),
                responseRate: drift.Value(data['responseRate'] ?? 'N/A'),
                about:
                    drift.Value(data['about'] ?? 'Tell others about yourself.'),
                hostedExperiences: drift.Value(data['hostedExperiences'] ?? 0),
                joinedExperiences: drift.Value(data['joinedExperiences'] ?? 0),
                photoURL: drift.Value(photoURL),
                isDirty: drift.Value(markDirty),
                lastSyncedAt: drift.Value(DateTime.now()),
              ),
            );
            print('✓ User profile created in local database with photo');
          } else {
            // Document doesn't exist in Firestore - user likely just logged in
            // Photo URL is already updated in Firestore, skip local DB for now
            print(
                '⚠️ User document not found in Firestore. Photo URL saved to Firestore only.');
          }
        } catch (e) {
          print('⚠️ Could not fetch user from Firestore: $e');
          print('Photo URL saved to Firestore, local DB update skipped.');
        }
      }
    } catch (e) {
      print('❌ Failed to update local database: $e');
      // Don't rethrow - photo is already uploaded and Firestore is updated
      print('Note: Photo upload succeeded, only local cache update failed.');
    }
  }

  /// Sync pending profile picture uploads
  Future<void> syncPendingUploads() async {
    final dirtyUsers = await _database.getDirtyUsers();

    for (final driftUser in dirtyUsers) {
      // Skip if photoURL is already a Firebase URL
      if (driftUser.photoURL == null ||
          driftUser.photoURL!.startsWith('http')) {
        continue;
      }

      try {
        // photoURL is a local path, upload it
        final localFile = File(driftUser.photoURL!);
        if (!await localFile.exists()) {
          print('⚠️ Local profile picture not found: ${driftUser.photoURL}');
          continue;
        }

        final bytes = await localFile.readAsBytes();
        final downloadUrl = await _uploadToFirebaseStorage(
          bytes,
          driftUser.id,
        );

        // Update Firestore
        await _updateFirestore(downloadUrl);

        // Update local database with Firebase URL
        await _updateLocalDatabase(downloadUrl, markDirty: false);

        print('✓ Synced profile picture for user ${driftUser.id}');
      } catch (e) {
        print('❌ Failed to sync profile picture for ${driftUser.id}: $e');
      }
    }
  }

  /// Delete old profile picture from Firebase Storage
  Future<void> deleteOldProfilePicture(String? oldPhotoURL) async {
    if (oldPhotoURL == null || oldPhotoURL.isEmpty) return;

    // Only try to delete if it's a Firebase Storage URL
    if (!oldPhotoURL.startsWith('http')) {
      print('ℹ️ Old photo is a local path, skipping deletion');
      return;
    }

    try {
      final ref = _storage.refFromURL(oldPhotoURL);
      await ref.delete();
      print('✓ Old profile picture deleted from Firebase');
    } catch (e) {
      print(
          'ℹ️ Could not delete old profile picture: ${e.toString().split('\n').first}');
      // Not critical if deletion fails
    }
  }

  /// Get local profile pictures directory
  Future<Directory?> getLocalProfilePicturesDirectory() async {
    try {
      Directory? picturesDir;

      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories(
            type: StorageDirectory.pictures);
        if (externalDirs != null && externalDirs.isNotEmpty) {
          final basePath = externalDirs.first.path.split('/Android')[0];
          picturesDir = Directory('$basePath/Pictures/Travel Connect');
        }
      } else if (Platform.isIOS) {
        final appDir = await getApplicationDocumentsDirectory();
        picturesDir = Directory('${appDir.path}/Travel Connect');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        picturesDir = Directory('${appDir.path}/Travel Connect');
      }

      return picturesDir;
    } catch (e) {
      print('Error getting local profile pictures directory: $e');
      return null;
    }
  }
}
