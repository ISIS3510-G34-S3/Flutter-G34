import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';

/// Experience detail screen showing full information about an experience
class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({
    super.key,
    required this.experienceId,
  });

  final String experienceId;

  @override
  Widget build(BuildContext context) {
    final experience = MockData.getExperienceById(experienceId);

    if (experience == null) {
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
          _buildSliverAppBar(context, experience),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and rating section
                _buildTitleSection(experience),

                // Host section
                _buildHostSection(experience),

                // About section
                _buildAboutSection(experience),

                // Skills exchange section
                _buildSkillsSection(experience),

                const SizedBox(height: 120), // Space for bottom actions
              ],
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: _buildBottomActions(context, experience),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Experience experience) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.forestGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image placeholder
            Container(
              color: AppColors.peach.withValues(alpha: 0.3),
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
                    'Experience Photo',
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
                gradient: AppColors.overlayGradient,
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
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
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
                      '${experience.rating} (${experience.reviewCount} reviews)',
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
                    experience.location,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostSection(Experience experience) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.peach.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 30,
              color: AppColors.oliveGold.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(width: 16),

          // Host info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      experience.host.name,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (experience.host.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.forestGreen,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Host since ${experience.host.memberSince}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 8),

                // Host meta info
                Wrap(
                  spacing: 16,
                  children: [
                    Text(
                      'Verified • Speaks ${experience.host.languages.length} languages • ${experience.host.responseRate} response rate',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            experience.description,
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
            color: AppColors.textPrimary.withValues(alpha: 0.1),
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
                onPressed: () => _messageHost(context, experience.host.id),
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message Host'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Book Experience button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _bookExperience(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Book Experience'),
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
    context.push('/booking/$experienceId');
  }
}
