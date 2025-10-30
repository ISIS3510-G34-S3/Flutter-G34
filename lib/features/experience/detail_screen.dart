import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_connect/models/host.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/experience_service.dart';
import 'package:travel_connect/services/host_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Experience detail screen showing full information about an experience
class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({
    super.key,
    required this.experienceId,
  });

  final String experienceId;

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final ExperienceService _experienceService = ExperienceService();
  final HostService _hostService = HostService();
  Experience? _experience;
  Host? _host;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchExperience();
  }

  Future<void> _fetchExperience() async {
    try {
      final experience =
          await _experienceService.getExperienceById(widget.experienceId);

      Host? host;
      if (experience != null) {
        try {
          host = await _hostService.getHostById(experience.hostId);
        } catch (e) {
          debugPrint('Error fetching host data: $e');
        }
      }

      if (mounted) {
        setState(() {
          _experience = experience;
          _host = host;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching experience: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_experience == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Experience Not Found'),
        ),
        body: const Center(
          child: Text('Experience not found'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          _buildSliverAppBar(context, _experience!),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and rating section
                _buildTitleSection(_experience!),

                // Photo gallery section
                if (_experience!.images.isNotEmpty)
                  _buildPhotoGallery(_experience!),

                // Price and details section
                _buildPriceAndDetailsSection(_experience!),

                // Host section
                if (_host != null) _buildHostSection(_experience!),

                // Location section
                _buildLocationSection(_experience!),

                // Categories section
                if (_experience!.categories.isNotEmpty)
                  _buildCategoriesSection(_experience!),

                // Accessibility Features section
                if (_experience!.accessibilityFeatures.isNotEmpty)
                  _buildAccessibilitySection(_experience!),

                // About section
                _buildAboutSection(_experience!),

                // Skills exchange section
                _buildSkillsSection(_experience!),

                const SizedBox(height: 120), // Space for bottom actions
              ],
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: _buildBottomActions(context, _experience!),
    );
  }

  /// Format price for display
  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }

  Widget _buildPhotoGallery(Experience experience) {
    if (experience.images.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: experience.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () =>
                    _viewImageFullscreen(context, experience.images, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: experience.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.peach.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.peach.withOpacity(0.3),
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Page indicators
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                experience.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewImageFullscreen(
      BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildPriceAndDetailsSection(Experience experience) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Price
          Row(
            children: [
              const Icon(Icons.attach_money,
                  color: AppColors.forestGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Price:',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatPrice(experience.priceCOP)} COP',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.forestGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Duration
          Row(
            children: [
              const Icon(Icons.schedule,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Duration:',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${experience.duration} hours',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Max group size
          Row(
            children: [
              const Icon(Icons.group, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Max Group Size:',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${experience.groupSizeMax} people',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Reviews summary
          if (experience.reviewsCount > 0) ...[
            const Divider(height: 24),
            InkWell(
              onTap: () {
                // TODO: Navigate to reviews section
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reviews feature coming soon')),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.oliveGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reviews:',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${experience.avgRating.toStringAsFixed(1)} ★',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.oliveGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${experience.reviewsCount})',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHostSection(Experience experience) {
    if (_host == null) return const SizedBox.shrink();

    final host = _host!;
    final displayName = host.name;
    final photoURL = host.photoURL;
    final isVerified = host.isVerified;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hosted by',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Host avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: photoURL != null && photoURL.isNotEmpty
                    ? NetworkImage(photoURL)
                    : null,
                backgroundColor: AppColors.forestGreen.withValues(alpha: 0.2),
                child: photoURL == null || photoURL.isEmpty
                    ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.forestGreen,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.forestGreen,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // View profile button
              OutlinedButton(
                onPressed: () {
                  context.push('/profile/${host.id}');
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('View Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Experience experience) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.lava,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  experience.department.isNotEmpty
                      ? experience.department
                      : 'Location not specified',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Embedded map
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    experience.location.latitude,
                    experience.location.longitude,
                  ),
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(experience.id),
                    position: LatLng(
                      experience.location.latitude,
                      experience.location.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: experience.title,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(Experience experience) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: experience.categories.map((category) {
              return Chip(
                label: Text(category),
                backgroundColor: AppColors.peach.withValues(alpha: 0.3),
                labelStyle: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                side: const BorderSide(color: AppColors.oliveGold),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(Experience experience) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.accessible, color: AppColors.forestGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Accessibility Features',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...experience.accessibilityFeatures.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.forestGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Experience experience) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.forestGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (experience.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: experience.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppColors.peach.withOpacity(0.3)),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.peach.withOpacity(0.3),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 48,
                        color: AppColors.oliveGold,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Image Unavailable',
                        style: TextStyle(
                          color: AppColors.oliveGold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                color: AppColors.peach.withOpacity(0.3),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: AppColors.oliveGold,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No Image Available',
                      style: TextStyle(
                        color: AppColors.oliveGold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            // Gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(Experience experience) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.title,
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Rating chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.oliveGold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${experience.avgRating.toStringAsFixed(1)} (${experience.reviewsCount} reviews)',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    experience.department,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed unused host section

  Widget _buildAboutSection(Experience experience) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this experience',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            experience.summary,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(Experience experience) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills Exchange',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // You'll learn section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'ll learn:',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...experience.skillsToLearn.map((skill) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• $skill',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // You'll teach section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lava.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  size: 20,
                  color: AppColors.lava,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'ll teach:',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...experience.skillsToTeach.map((skill) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• $skill',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Experience experience) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message Host button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _messageHost(context, experience.hostId),
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Book Experience button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _bookExperience(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Book'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _messageHost(BuildContext context, String hostId) {
    context.push('/messaging/$hostId');
  }

  void _bookExperience(BuildContext context) {
    context.push('/booking/${widget.experienceId}');
  }
}

/// Fullscreen image viewer with swipe navigation
class _FullscreenImageViewer extends StatefulWidget {
  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
