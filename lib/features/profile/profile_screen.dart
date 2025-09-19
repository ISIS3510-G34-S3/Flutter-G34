import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';

/// Profile screen showing user information and verification status
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profileId,
  });

  final String profileId;

  @override
  Widget build(BuildContext context) {
    // For this demo, we'll always show the current user profile
    final user = MockData.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _editProfile(context),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.white,
            ),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header card
          _buildProfileHeader(user),

          const SizedBox(height: 16),

          // Verification banner
          if (!user.isVerified) _buildVerificationBanner(context),

          const SizedBox(height: 16),

          // About section
          _buildAboutSection(user),

          const SizedBox(height: 16),

          // Languages section
          _buildLanguagesSection(user),

          const SizedBox(height: 16),

          // My experiences section
          _buildExperiencesSection(user),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Host user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.peach.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: AppColors.oliveGold.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(width: 20),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (user.isVerified)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 20,
                            color: AppColors.forestGreen,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.oliveGold.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 20,
                            color: AppColors.oliveGold.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member since ${user.memberSince}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildVerificationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.peach.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.oliveGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.oliveGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_outlined,
              color: AppColors.oliveGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get Verified',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verify your identity to build trust with other users and unlock more features.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pushNamed('profile-verification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.oliveGold,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Start Verification'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Host user) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.about,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesSection(Host user) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.language,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Languages',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...user.languages.map((language) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.forestGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        language,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencesSection(Host user) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Experiences',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Hosted experiences
                Expanded(
                  child: _buildExperienceCounter(
                    count: user.hostedExperiences,
                    label: 'Hosted',
                    color: AppColors.forestGreen,
                  ),
                ),

                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // Joined experiences
                Expanded(
                  child: _buildExperienceCounter(
                    count: user.joinedExperiences,
                    label: 'Joined',
                    color: AppColors.lava,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCounter({
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTypography.displaySmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Profile editing coming soon! You\'ll be able to update your information, add photos, and manage your experience listings.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
