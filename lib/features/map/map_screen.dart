import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';

/// Map screen showing experience locations with pins
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Experience? _selectedExperience;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Map View',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Map grid background
          _buildMapGrid(),

          // Map pins
          _buildMapPins(),

          // Zoom controls
          _buildZoomControls(),

          // Bottom sheet for selected experience
          if (_selectedExperience != null)
            _buildBottomSheet(_selectedExperience!),
        ],
      ),
    );
  }

  Widget _buildMapGrid() {
    return Container(
      color: AppColors.background,
      child: CustomPaint(
        painter: GridPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildMapPins() {
    return Stack(
      children: MockData.experiences.map((experience) {
        // Extract latitude and longitude from experience location
        final double latitude = experience.location['latitude'] ?? 0.0;
        final double longitude = experience.location['longitude'] ?? 0.0;
        
        // Determine pin type based on rating (primary for 4.8+ rating)
        final bool isPrimaryPin = experience.avgRating >= 4.8;

        return Positioned(
          left: (longitude + 80) * 4, // Mock positioning
          top: (latitude - 3) * 100 + 200, // Mock positioning
          child: GestureDetector(
            onTap: () => _selectExperience(experience),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPrimaryPin
                    ? AppColors.forestGreen
                    : AppColors.earthBrown,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: 16,
      top: 100,
      child: Column(
        children: [
          // Zoom in button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _zoomIn,
              icon: const Icon(
                Icons.add,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Zoom in',
            ),
          ),

          const SizedBox(height: 8),

          // Zoom out button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _zoomOut,
              icon: const Icon(
                Icons.remove,
                color: AppColors.textPrimary,
              ),
              tooltip: 'Zoom out',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(Experience experience) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.2),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          experience.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Rating chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.oliveGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              experience.avgRating.toString(),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Host and location
                  Row(
                    children: [
                      Text(
                        experience.hostName,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (experience.isHostVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.forestGreen,
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        experience.department,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Skills
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Learn skills
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: AppColors.forestGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              experience.skillsToLearn.join(', '),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Teach skills
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outlined,
                            size: 16,
                            color: AppColors.lava,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              experience.skillsToTeach.join(', '),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // View Details button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _viewExperienceDetails(experience.id),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectExperience(Experience experience) {
    setState(() {
      _selectedExperience = experience;
    });
  }

  void _zoomIn() {
    // Mock zoom functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zooming in...'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void _zoomOut() {
    // Mock zoom functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zooming out...'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void _viewExperienceDetails(String experienceId) {
    context.push('/experience/$experienceId');
  }
}

/// Custom painter for drawing the map grid
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
