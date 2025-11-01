import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'image_processing_service.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

/// Service for managing user profile pictures
class ProfilePictureService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://travelappbd-8e204.firebasestorage.app',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppDatabase _database = AppDatabase();

  /// Pick and upload a profile picture from camera or gallery
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
      await _saveToLocalStorage(compressedBytes, user.uid);

      // Upload to Firebase Storage
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
  /// Using 'experiences' path which has proper security rules configured
  Future<String> _uploadToFirebaseStorage(
    Uint8List imageBytes,
    String userId,
  ) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String fileName = 'profile_$timestamp.jpg';
    // Use experiences path which has proper security rules
    final ref = _storage.ref().child('experiences/$userId/$fileName');

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
  Future<void> _updateLocalDatabase(String photoURL) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docId = (user.email ?? '').toLowerCase().isNotEmpty
        ? (user.email ?? '').toLowerCase()
        : user.uid;

    // Get existing user data
    final existingUser = await _database.getUserById(docId);
    if (existingUser != null) {
      // Update existing user
      await _database.upsertUser(
        UsersCompanion(
          id: drift.Value(docId),
          photoURL: drift.Value(photoURL),
          isDirty: const drift.Value(false),
          lastSyncedAt: drift.Value(DateTime.now()),
        ),
      );
    } else {
      // Create new user entry if it doesn't exist
      await _database.upsertUser(
        UsersCompanion(
          id: drift.Value(docId),
          name: drift.Value(user.displayName ?? 'User'),
          email: drift.Value(user.email ?? ''),
          photoURL: drift.Value(photoURL),
          avgHostRating: const drift.Value(0.0),
          isVerified: const drift.Value(false),
          memberSince: drift.Value(DateTime.now()),
          languages: const drift.Value('[]'),
          responseRate: const drift.Value('N/A'),
          about: const drift.Value('Tell others about yourself.'),
          hostedExperiences: const drift.Value(0),
          joinedExperiences: const drift.Value(0),
          isDirty: const drift.Value(false),
          lastSyncedAt: drift.Value(DateTime.now()),
        ),
      );
    }

    print('✓ Profile picture URL updated in local database');
  }

  /// Delete old profile picture from Firebase Storage
  Future<void> deleteOldProfilePicture(String? oldPhotoURL) async {
    if (oldPhotoURL == null || oldPhotoURL.isEmpty) return;

    try {
      final ref = _storage.refFromURL(oldPhotoURL);
      await ref.delete();
      print('✓ Old profile picture deleted from Firebase');
    } catch (e) {
      print('Could not delete old profile picture: $e');
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
