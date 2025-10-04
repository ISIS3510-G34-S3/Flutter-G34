import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../mock/mock_data.dart';

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
            // Experience image placeholder
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

                  // Host and location
                  _buildHostSection(),

                  const SizedBox(height: 12),

                  // Skills section
                  _buildSkillsSection(),

                  const SizedBox(height: 12),

                  // Reviews and time
                  _buildMetaSection(),
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
        color: AppColors.peach.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 32,
              color: AppColors.oliveGold.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Experience Photo',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.oliveGold.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
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
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 8),

        // Rating chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildHostSection() {
    return Row(
      children: [
        // Avatar placeholder
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.peach.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline,
            size: 18,
            color: AppColors.oliveGold.withValues(alpha: 0.7),
          ),
        ),

        const SizedBox(width: 8),

        // Host name with verified check
        Expanded(
          child: Row(
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
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Location with pin icon
        Row(
          children: [
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
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Learn skills
        if (experience.skillsToLearn.isNotEmpty) ...[
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
        ],

        // Teach skills
        if (experience.skillsToTeach.isNotEmpty) ...[
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
      ],
    );
  }

  Widget _buildMetaSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Review count
        Text(
          '(${experience.reviewsCount} reviews)',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // Time ago
        Text(
          '${DateTime.now().difference(experience.createdAt).inDays} days ago',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
