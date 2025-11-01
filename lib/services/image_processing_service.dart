import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service for processing images using Isolates (multi-threading)
class ImageProcessingService {
  /// Compress and resize image in a separate isolate to avoid blocking UI
  static Future<Uint8List> compressImage({
    required String imagePath,
    int maxWidth = 1920,
    int quality = 85,
  }) async {
    final params = _ImageCompressionParams(
      imagePath: imagePath,
      maxWidth: maxWidth,
      quality: quality,
    );

    // ✅ Run in separate isolate (true multi-threading)
    return await compute(_compressImageIsolate, params);
  }

  /// Isolate function - must be top-level or static
  static Future<Uint8List> _compressImageIsolate(
      _ImageCompressionParams params) async {
    try {
      // Read image file
      final imageFile = File(params.imagePath);
      final bytes = await imageFile.readAsBytes();
      final originalSize = bytes.length;

      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final originalWidth = image.width;
      final originalHeight = image.height;

      // Resize if needed
      if (image.width > params.maxWidth) {
        image = img.copyResize(image, width: params.maxWidth);
        print('📐 Resized from ${originalWidth}x${originalHeight} to ${image.width}x${image.height}');
      } else {
        print('📐 Image size ${originalWidth}x${originalHeight} (no resize needed)');
      }

      // Compress as JPEG
      final compressed = Uint8List.fromList(img.encodeJpg(image, quality: params.quality));
      final compressedSize = compressed.length;
      final savingsPercent = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);
      
      print('🗜️ Image Compression:');
      print('   Original: ${_formatBytes(originalSize)}');
      print('   Compressed: ${_formatBytes(compressedSize)}');
      print('   Saved: $savingsPercent% (${_formatBytes(originalSize - compressedSize)})');
      
      return compressed;
    } catch (e) {
      print('❌ Error compressing image: $e');
      rethrow;
    }
  }

  /// Format bytes to human-readable size
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Parameters for image compression
class _ImageCompressionParams {
  final String imagePath;
  final int maxWidth;
  final int quality;

  _ImageCompressionParams({
    required this.imagePath,
    required this.maxWidth,
    required this.quality,
  });
}

