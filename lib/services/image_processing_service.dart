import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
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

      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed
      if (image.width > params.maxWidth) {
        image = img.copyResize(image, width: params.maxWidth);
      }

      // Compress as JPEG
      return Uint8List.fromList(img.encodeJpg(image, quality: params.quality));
    } catch (e) {
      print('Error compressing image: $e');
      rethrow;
    }
  }

  /// Compress multiple images in parallel using multiple isolates
  static Future<List<Uint8List>> compressMultipleImages({
    required List<String> imagePaths,
    int maxWidth = 1920,
    int quality = 85,
  }) async {
    // Create compression tasks for each image
    final futures = imagePaths.map((path) {
      return compressImage(
        imagePath: path,
        maxWidth: maxWidth,
        quality: quality,
      );
    }).toList();

    // ✅ Run all compressions in parallel (multiple isolates)
    return await Future.wait(futures);
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


