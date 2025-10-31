import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service for managing locally stored media files (images and videos)
class LocalMediaService {
  static const String _mediaFolderName = 'Travel Connect';

  /// Get the local media directory
  Future<Directory> getMediaDirectory() async {
    Directory? mediaDir;

    if (Platform.isAndroid) {
      // On Android, use external storage Pictures directory
      final externalDirs =
          await getExternalStorageDirectories(type: StorageDirectory.pictures);
      if (externalDirs != null && externalDirs.isNotEmpty) {
        // Use public Pictures directory
        final basePath = externalDirs.first.path.split('/Android')[0];
        mediaDir = Directory('$basePath/Pictures/$_mediaFolderName');
      }
    } else if (Platform.isIOS) {
      // On iOS, use app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      mediaDir = Directory('${appDir.path}/$_mediaFolderName');
    } else {
      // Fallback for other platforms
      final appDir = await getApplicationDocumentsDirectory();
      mediaDir = Directory('${appDir.path}/$_mediaFolderName');
    }

    if (mediaDir == null) {
      // Final fallback
      final appDir = await getApplicationDocumentsDirectory();
      mediaDir = Directory('${appDir.path}/$_mediaFolderName');
    }

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    return mediaDir;
  }

  /// Get all locally stored media files
  Future<List<File>> getAllLocalMedia() async {
    try {
      final mediaDir = await getMediaDirectory();
      final List<FileSystemEntity> entities = await mediaDir.list().toList();

      return entities
          .whereType<File>()
          .where((file) => _isMediaFile(file.path))
          .toList();
    } catch (e) {
      print('Error getting local media: $e');
      return [];
    }
  }

  /// Check if a file is a media file (image or video)
  bool _isMediaFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'].contains(extension);
  }

  /// Get only images
  Future<List<File>> getLocalImages() async {
    final allMedia = await getAllLocalMedia();
    return allMedia.where((file) {
      final extension = file.path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png'].contains(extension);
    }).toList();
  }

  /// Get only videos
  Future<List<File>> getLocalVideos() async {
    final allMedia = await getAllLocalMedia();
    return allMedia.where((file) {
      final extension = file.path.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi'].contains(extension);
    }).toList();
  }

  /// Save a file to local media directory
  Future<File> saveMediaFile(File sourceFile, String fileName) async {
    final mediaDir = await getMediaDirectory();
    final targetPath = '${mediaDir.path}/$fileName';
    return await sourceFile.copy(targetPath);
  }

  /// Delete a local media file
  Future<bool> deleteMediaFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting media file: $e');
      return false;
    }
  }

  /// Get the size of the media directory in bytes
  Future<int> getMediaDirectorySize() async {
    try {
      final mediaDir = await getMediaDirectory();
      final List<FileSystemEntity> entities = await mediaDir.list().toList();

      int totalSize = 0;
      for (var entity in entities.whereType<File>()) {
        totalSize += await entity.length();
      }

      return totalSize;
    } catch (e) {
      print('Error calculating media directory size: $e');
      return 0;
    }
  }

  /// Format bytes to human-readable size
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Clear all local media (use with caution!)
  Future<void> clearAllLocalMedia() async {
    try {
      final mediaDir = await getMediaDirectory();
      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
        await mediaDir.create(recursive: true);
      }
    } catch (e) {
      print('Error clearing local media: $e');
    }
  }
}
