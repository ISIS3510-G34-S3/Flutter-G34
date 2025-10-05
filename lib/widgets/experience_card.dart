import 'package:flutter/material.dart';
import 'package:travel_connect/models/experience.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Experience card widget for displaying experience information in lists
class ExperienceCard extends StatelessWidget {
  const ExperienceCard({
    super.key,
    required this.experience,
    required this.onTap,
  });

  final Experience experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Experience image
            _buildImageSection(),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  _buildTitleSection(),

                  const SizedBox(height: 8),

                  // Location
                  _buildLocationSection(),

                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '\$${experience.priceCOP} COP',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.forestGreen,
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

  Widget _buildImageSection() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        image: experience.images.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(experience.images.first),
                fit: BoxFit.cover,
              )
            : null,
        color: experience.images.isEmpty
            ? AppColors.peach.withOpacity(0.3)
            : Colors.transparent,
      ),
      child: experience.images.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 32,
                    color: AppColors.oliveGold.withOpacity(0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Image Available',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.oliveGold.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Expanded(
          child: Text(
            experience.title,
            style: AppTypography.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 16),

        // Rating
        Row(
          children: [
            const Icon(
              Icons.star,
              color: AppColors.oliveGold,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              experience.avgRating.toStringAsFixed(1),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            experience.department,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
