import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_cache_service.dart';
import '../theme/colors.dart';

/// Widget that displays an experience image, trying local cache first,
/// then network. This ensures offline viewing for cached images.
class CachedExperienceImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const CachedExperienceImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<CachedExperienceImage> createState() => _CachedExperienceImageState();
}

class _CachedExperienceImageState extends State<CachedExperienceImage> {
  final ImageCacheService _cacheService = ImageCacheService();
  String? _localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Try to get cached image path first
      final cachedPath =
          await _cacheService.getCachedImagePath(widget.imageUrl);
      if (mounted) {
        setState(() {
          _localPath = cachedPath;
          _isLoading = false;
        });

        if (cachedPath != null) {
          debugPrint('✅ Using cached image: $cachedPath');
        } else {
          debugPrint('⚠️ No cached image for: ${widget.imageUrl}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading cached image: $e');
      if (mounted) {
        setState(() {
          _localPath = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: AppColors.peach.withOpacity(0.3),
          borderRadius: widget.borderRadius,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // If we have a local cached file, use it
    if (_localPath != null) {
      final file = File(_localPath!);
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Image.file(
          file,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          errorBuilder: (context, error, stackTrace) {
            // If local file fails, fall back to network
            return _buildNetworkImage();
          },
        ),
      );
    }

    // Fall back to network image if no local cache
    return _buildNetworkImage();
  }

  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        placeholder: (context, url) => Container(
          height: widget.height,
          width: widget.width,
          color: AppColors.peach.withOpacity(0.3),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: widget.height,
          width: widget.width,
          color: AppColors.peach.withOpacity(0.3),
          child: const Icon(
            Icons.broken_image,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
