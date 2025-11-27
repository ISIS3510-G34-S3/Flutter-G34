import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_connect/services/host_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/host.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/connectivity_wrapper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import '../../services/profile_picture_service.dart';
import '../../services/profile_service.dart';
import '../../database/app_database.dart';

/// Profile screen showing user information and verification status
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profileId,
  });

  final String profileId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with ConnectivityAware {
  final HostService _hostService = HostService();
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  final ProfileService _profileService = ProfileService();
  bool _isUploadingPhoto = false;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    // Start monitoring connectivity for profile updates
    _profileService.startConnectivityMonitoring();
  }

  @override
  void dispose() {
    _profileService.dispose();
    super.dispose();
  }

  /// Show dialog to choose photo source
  Future<void> _showPhotoUploadDialog(Host user) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            'Profile Picture',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.forestGreen,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadProfilePicture(ImageSource.camera, user);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.oliveGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.oliveGold,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _uploadProfilePicture(ImageSource.gallery, user);
                },
              ),
              if (user.photoURL != null && user.photoURL!.isNotEmpty)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lava.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.lava,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.lava,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeProfilePicture(user);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Upload profile picture
  Future<void> _uploadProfilePicture(ImageSource source, Host user) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final String? photoURL =
          await _profilePictureService.uploadProfilePicture(source: source);

      if (photoURL != null) {
        // Delete old profile picture if it exists
        await _profilePictureService.deleteOldProfilePicture(user.photoURL);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.forestGreen,
          ),
        );

        // Force refresh the profile to show new picture from server
        setState(() {
          _isUploadingPhoto = false;
          _refreshKey++; // Force FutureBuilder to reload
        });

        // Clear old image from cache
        if (user.photoURL != null && user.photoURL!.startsWith('http')) {
          await CachedNetworkImage.evictFromCache(user.photoURL!);
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload profile picture: $e'),
          backgroundColor: AppColors.lava,
        ),
      );
    }
  }

  /// Remove profile picture
  Future<void> _removeProfilePicture(Host user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Profile Picture',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove your profile picture?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remove',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.lava,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isUploadingPhoto = true;
      });

      try {
        // Delete old profile picture
        await _profilePictureService.deleteOldProfilePicture(user.photoURL);

        // Update Firestore and local database to remove photoURL
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser != null) {
          final docId = (authUser.email ?? '').toLowerCase().isNotEmpty
              ? (authUser.email ?? '').toLowerCase()
              : authUser.uid;

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({
            'photoURL': FieldValue.delete(),
          });

          // Update local database
          final db = AppDatabase();
          await db.upsertUser(
            UsersCompanion(
              id: drift.Value(docId),
              photoURL: const drift.Value(null),
              isDirty: const drift.Value(false),
              lastSyncedAt: drift.Value(DateTime.now()),
            ),
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully!'),
            backgroundColor: AppColors.forestGreen,
          ),
        );

        setState(() {
          _isUploadingPhoto = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove profile picture: $e'),
            backgroundColor: AppColors.lava,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: FutureBuilder<Host?>(
        key: ValueKey(_refreshKey),
        future: _hostService.getCurrentUserHost(forceRefresh: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Text(
                'Could not load user profile.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return Column(
            children: [
              // Edit profile button in app bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.forestGreen),
                    onPressed: () => _editProfile(context, user),
                    tooltip: 'Edit Profile',
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildOfflineBanner(),
                    _buildProfileHeader(user),
                    const SizedBox(height: 16),
                    if (!user.isVerified) _buildVerificationBanner(context),
                    const SizedBox(height: 16),
                    _buildAboutSection(user),
                    const SizedBox(height: 16),
                    _buildLanguagesSection(user),
                    const SizedBox(height: 16),
                    _buildExperiencesSection(user),
                    const SizedBox(height: 16),
                    _buildAchievementsSection(),
                    const SizedBox(height: 16),
                    _buildSettingsSection(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
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
            // Avatar with upload functionality
            GestureDetector(
              onTap: () => _showPhotoUploadDialog(user),
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.peach.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingPhoto
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : user.photoURL != null && user.photoURL!.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.photoURL!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person_outline,
                                    size: 40,
                                    color: AppColors.oliveGold
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 40,
                                color:
                                    AppColors.oliveGold.withValues(alpha: 0.7),
                              ),
                  ),
                  if (!_isUploadingPhoto)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
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
            if (user.languages.isEmpty)
              Text(
                'No languages added yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.languages.map((language) {
                  return Chip(
                    label: Text(language),
                    backgroundColor:
                        AppColors.forestGreen.withValues(alpha: 0.1),
                    labelStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: AppColors.forestGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  );
                }).toList(),
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Experiences',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/my-experiences'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: _profileService.getExperienceCounts(user.id),
              builder: (context, snapshot) {
                // Use data from snapshot if available, otherwise fall back to user values
                final hostedCount =
                    snapshot.data?['hosted'] ?? user.hostedExperiences;
                final joinedCount =
                    snapshot.data?['joined'] ?? user.joinedExperiences;

                return Row(
                  children: [
                    // Hosted experiences
                    Expanded(
                      child: _buildExperienceCounter(
                        count: hostedCount,
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
                        count: joinedCount,
                        label: 'Joined',
                        color: AppColors.lava,
                      ),
                    ),
                  ],
                );
              },
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

  Widget _buildAchievementsSection() {
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
                  Icons.emoji_events,
                  size: 20,
                  color: AppColors.oliveGold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildAchievementItem(
                  icon: Icons.hotel,
                  title: 'Super Host',
                  color: AppColors.forestGreen,
                ),
                _buildAchievementItem(
                  icon: Icons.star,
                  title: '5 Star Host',
                  color: AppColors.oliveGold,
                ),
                _buildAchievementItem(
                  icon: Icons.flash_on,
                  title: 'Fast Responder',
                  color: AppColors.lava,
                ),
                _buildAchievementItem(
                  icon: Icons.people,
                  title: 'Skill Sharer',
                  color: AppColors.peach,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
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
                  Icons.settings,
                  size: 20,
                  color: AppColors.forestGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              onTap: () =>
                  _showComingSoonDialog(context, 'Notification Preferences'),
            ),
            _buildSettingItem(
              icon: Icons.photo_library_outlined,
              title: 'Local Media Storage',
              onTap: () => context.push('/local-media'),
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Settings',
              onTap: () => _showComingSoonDialog(context, 'Privacy Settings'),
            ),
            _buildSettingItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () => _showComingSoonDialog(context, 'Payment Methods'),
            ),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: 'Language & Region',
              onTap: () => _showComingSoonDialog(context, 'Language & Region'),
            ),
            _buildSettingItem(
              icon: Icons.attach_money_outlined,
              title: 'Currency Preferences',
              onTap: () => context.push('/currency-settings'),
            ),
            _buildSettingItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => _showComingSoonDialog(context, 'Help & Support'),
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: AppColors.divider,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () => _handleLogout(context),
              iconColor: AppColors.lava,
              textColor: AppColors.lava,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, Host user) async {
    final nameController = TextEditingController(text: user.name);
    final aboutController = TextEditingController(text: user.about);
    final selectedLanguages = List<String>.from(user.languages);
    final availableLanguages = [
      'English',
      'Spanish',
      'Portuguese',
      'French',
    ];

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _EditProfileScreen(
          nameController: nameController,
          aboutController: aboutController,
          selectedLanguages: selectedLanguages,
          availableLanguages: availableLanguages,
        ),
      ),
    );

    if (result == true) {
      // Save the profile updates
      try {
        final wasOnline = await _profileService.updateProfile(
          name: nameController.text.trim(),
          about: aboutController.text.trim(),
          languages: selectedLanguages,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasOnline
                  ? 'Profile updated successfully!'
                  : 'Profile saved offline. Will sync when online.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.forestGreen,
          ),
        );

        // Refresh the profile
        setState(() {});
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.lava,
          ),
        );
      }
    }

    nameController.dispose();
    aboutController.dispose();
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          feature,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This feature is coming soon! We\'re working hard to bring you the best experience.',
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log Out',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              // Router will automatically redirect to login due to auth state change
            },
            child: Text(
              'Log Out',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.lava,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen edit profile dialog
class _EditProfileScreen extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController aboutController;
  final List<String> selectedLanguages;
  final List<String> availableLanguages;

  const _EditProfileScreen({
    required this.nameController,
    required this.aboutController,
    required this.selectedLanguages,
    required this.availableLanguages,
  });

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Save',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Name field
          Card(
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
                      const Icon(Icons.person, color: AppColors.forestGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Name',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About field
          Card(
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
                      const Icon(Icons.info_outline,
                          color: AppColors.forestGreen),
                      const SizedBox(width: 8),
                      Text(
                        'About',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.aboutController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Tell others about yourself...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Languages section
          Card(
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
                      const Icon(Icons.language, color: AppColors.forestGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Languages',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Language selection chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.availableLanguages.map((lang) {
                      final isSelected =
                          widget.selectedLanguages.contains(lang);
                      return FilterChip(
                        label: Text(lang),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              widget.selectedLanguages.add(lang);
                            } else {
                              widget.selectedLanguages.remove(lang);
                            }
                          });
                        },
                        backgroundColor: AppColors.background,
                        selectedColor:
                            AppColors.forestGreen.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.forestGreen,
                        labelStyle: AppTypography.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.forestGreen
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.forestGreen
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 20, color: AppColors.forestGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your changes will be saved locally and synced when online.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
