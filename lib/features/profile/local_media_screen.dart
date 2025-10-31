import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/local_media_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Screen to view and manage locally stored media files
class LocalMediaScreen extends StatefulWidget {
  const LocalMediaScreen({super.key});

  @override
  State<LocalMediaScreen> createState() => _LocalMediaScreenState();
}

class _LocalMediaScreenState extends State<LocalMediaScreen> {
  final LocalMediaService _mediaService = LocalMediaService();
  List<File> _mediaFiles = [];
  bool _isLoading = true;
  String _storageSize = '0 B';
  String _filter = 'all'; // 'all', 'images', 'videos'

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<File> files;
      switch (_filter) {
        case 'images':
          files = await _mediaService.getLocalImages();
          break;
        case 'videos':
          files = await _mediaService.getLocalVideos();
          break;
        default:
          files = await _mediaService.getAllLocalMedia();
      }

      final size = await _mediaService.getMediaDirectorySize();

      if (!mounted) return;
      setState(() {
        _mediaFiles = files;
        _storageSize = _mediaService.formatBytes(size);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading media: $e'),
          backgroundColor: AppColors.lava,
        ),
      );
    }
  }

  Future<void> _deleteFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.lava)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _mediaService.deleteMediaFile(file);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deleted successfully'),
            backgroundColor: AppColors.forestGreen,
          ),
        );
        _loadMediaFiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete file'),
            backgroundColor: AppColors.lava,
          ),
        );
      }
    }
  }

  bool _isVideoFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Local Media'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
              _loadMediaFiles();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Media'),
              ),
              const PopupMenuItem(
                value: 'images',
                child: Text('Images Only'),
              ),
              const PopupMenuItem(
                value: 'videos',
                child: Text('Videos Only'),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Storage info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stored Media',
                            style: AppTypography.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_mediaFiles.length} files • $_storageSize',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (_mediaFiles.isNotEmpty)
                        TextButton(
                          onPressed: _confirmClearAll,
                          child: Text(
                            'Clear All',
                            style: TextStyle(color: AppColors.lava),
                          ),
                        ),
                    ],
                  ),
                ),

                // Media grid
                Expanded(
                  child: _mediaFiles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No local media files',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _mediaFiles.length,
                          itemBuilder: (context, index) {
                            final file = _mediaFiles[index];
                            final isVideo = _isVideoFile(file.path);

                            return GestureDetector(
                              onTap: () => _viewFile(file),
                              onLongPress: () => _deleteFile(file),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isVideo
                                        ? Container(
                                            color: AppColors.forestGreen
                                                .withOpacity(0.2),
                                            child: const Icon(
                                              Icons.play_circle_outline,
                                              size: 48,
                                              color: AppColors.forestGreen,
                                            ),
                                          )
                                        : Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: AppColors.peach
                                                    .withOpacity(0.3),
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                  if (isVideo)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.videocam,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Media'),
        content: const Text(
          'Are you sure you want to delete all locally stored media files? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All',
                style: TextStyle(color: AppColors.lava)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _mediaService.clearAllLocalMedia();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All media files deleted'),
          backgroundColor: AppColors.forestGreen,
        ),
      );
      _loadMediaFiles();
    }
  }

  void _viewFile(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FileViewerScreen(file: file),
      ),
    );
  }
}

/// Simple file viewer screen
class _FileViewerScreen extends StatelessWidget {
  const _FileViewerScreen({required this.file});

  final File file;

  bool _isVideoFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideoFile(file.path);
    final fileName = file.path.split('/').last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          fileName,
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: isVideo
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library,
                    size: 64,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Video Playback',
                    style:
                        AppTypography.bodyLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video player integration coming soon',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: AppTypography.bodyLarge
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
