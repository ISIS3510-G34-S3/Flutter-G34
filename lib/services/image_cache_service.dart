import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';

/// Service for caching images locally for offline access
class ImageCacheService {
  final AppDatabase _database = AppDatabase();

  /// Download and cache images for the first 3 experiences
  /// This ensures images are available offline
  Future<void> cacheImagesForTopExperiences(
      List<String> experienceIds, List<List<String>> imageUrls) async {
    print('📸 Starting image caching for top 3 experiences...');

    // Only cache first 3 experiences
    final experiencesToCache = experienceIds.take(3).toList();
    final imageUrlsToCache = imageUrls.take(3).toList();

    for (int i = 0; i < experiencesToCache.length; i++) {
      final experienceId = experiencesToCache[i];
      final urls = imageUrlsToCache[i];

      if (urls.isNotEmpty) {
        // Only cache the first image of each experience
        final firstImageUrl = urls.first;
        await _cacheImage(firstImageUrl, experienceId);
      }
    }

    print('✅ Image caching completed');
  }

  /// Download and cache a single image
  Future<void> _cacheImage(String imageUrl, String experienceId) async {
    try {
      // Check if already cached
      final existingCache = await _database.getCachedImageByUrl(imageUrl);
      if (existingCache != null) {
        // Verify file still exists
        final file = File(existingCache.localPath);
        if (await file.exists()) {
          print('✓ Image already cached: $imageUrl');
          return;
        } else {
          // File was deleted, remove from database and re-cache
          await _database.deleteCachedImage(imageUrl);
        }
      }

      print('⬇️ Downloading image: $imageUrl');

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        print('❌ Failed to download image: ${response.statusCode}');
        return;
      }

      // Get app's document directory for persistent storage
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory(p.join(directory.path, 'image_cache'));
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Generate a unique filename based on the URL hash
      final fileName =
          '${imageUrl.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = p.join(cacheDir.path, fileName);

      // Save the image to disk
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);

      // Save cache info to database
      await _database.saveCachedImage(
        CachedImagesCompanion(
          imageUrl: drift.Value(imageUrl),
          localPath: drift.Value(localPath),
          experienceId: drift.Value(experienceId),
          cachedAt: drift.Value(DateTime.now()),
          fileSize: drift.Value(response.bodyBytes.length),
        ),
      );

      print('✅ Cached image: $fileName (${response.bodyBytes.length} bytes)');
    } catch (e) {
      print('❌ Error caching image $imageUrl: $e');
    }
  }

  /// Get local path for a cached image, or null if not cached
  Future<String?> getCachedImagePath(String imageUrl) async {
    try {
      final cachedImage = await _database.getCachedImageByUrl(imageUrl);
      if (cachedImage != null) {
        // Verify file still exists
        final file = File(cachedImage.localPath);
        if (await file.exists()) {
          return cachedImage.localPath;
        } else {
          // File was deleted, remove from database
          await _database.deleteCachedImage(imageUrl);
        }
      }
    } catch (e) {
      print('Error getting cached image: $e');
    }
    return null;
  }

  /// Clear old cached images (optional, for cache management)
  Future<void> clearOldCache(
      {Duration maxAge = const Duration(days: 30)}) async {
    print('🗑️ Clearing old cached images...');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory(p.join(directory.path, 'image_cache'));

      if (await cacheDir.exists()) {
        final cutoffDate = DateTime.now().subtract(maxAge);

        // Get all cached images
        final images = await _database.select(_database.cachedImages).get();

        for (final image in images) {
          if (image.cachedAt.isBefore(cutoffDate)) {
            // Delete file
            final file = File(image.localPath);
            if (await file.exists()) {
              await file.delete();
            }

            // Remove from database
            await _database.deleteCachedImage(image.imageUrl);
            print('🗑️ Deleted old cache: ${image.localPath}');
          }
        }
      }

      print('✅ Old cache cleared');
    } catch (e) {
      print('Error clearing old cache: $e');
    }
  }
}
