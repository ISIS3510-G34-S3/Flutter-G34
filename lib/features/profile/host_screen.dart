import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_connect/models/host.dart';
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/host_service.dart';
import 'package:travel_connect/services/experience_service.dart';
import 'package:travel_connect/theme/colors.dart';
import 'package:travel_connect/theme/typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_connect/widgets/experience_card.dart';
import 'package:travel_connect/widgets/connectivity_wrapper.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_connect/features/messaging/chat_detail_screen.dart';
import 'package:travel_connect/services/chat_service.dart';

class HostScreen extends StatefulWidget {
  final String hostId;
  const HostScreen({super.key, required this.hostId});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> with ConnectivityAware {
  final HostService _hostService = HostService();
  final ExperienceService _experienceService = ExperienceService();
  Host? _host;
  List<Experience> _hostExperiences = [];
  bool _isLoading = true;
  bool _isLoadingExperiences = true;

  @override
  void initState() {
    super.initState();
    _fetchHost();
  }

  Future<void> _fetchHost() async {
    try {
      // Force refresh from server to get latest profile picture and data
      final host =
          await _hostService.getHostById(widget.hostId, forceRefresh: true);
      if (mounted) {
        setState(() {
          _host = host;
          _isLoading = false;
        });
      }

      // Fetch host's experiences
      _fetchHostExperiences();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching host: $e');
    }
  }

  Future<void> _fetchHostExperiences() async {
    try {
      final experiences =
          await _experienceService.getExperiencesByHost(widget.hostId);
      if (mounted) {
        setState(() {
          _hostExperiences = experiences;
          _isLoadingExperiences = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingExperiences = false;
        });
      }
      debugPrint('Error fetching host experiences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _host?.name ?? 'Host Profile',
          style: AppTypography.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _host == null
              ? const Center(child: Text('Host not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildOfflineBanner(),
                    _buildProfileHeader(_host!),
                    const SizedBox(height: 16),
                    _buildRatingSection(_host!),
                    const SizedBox(height: 16),
                    if (_host!.about.isNotEmpty) ...[
                      _buildAboutSection(_host!),
                      const SizedBox(height: 16),
                    ],
                    if (_host!.languages.isNotEmpty) ...[
                      _buildLanguagesSection(_host!),
                      const SizedBox(height: 16),
                    ],
                    _buildExperiencesSection(_host!),
                  ],
                ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildProfileHeader(Host host) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Hero(
              tag: 'host-avatar-${host.id}',
              child: host.photoURL != null && host.photoURL!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: host.photoURL!,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 40,
                        backgroundImage: imageProvider,
                        backgroundColor: AppColors.peach.withOpacity(0.3),
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.peach.withOpacity(0.3),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.peach.withOpacity(0.3),
                        child: Text(
                          host.name.isNotEmpty
                              ? host.name[0].toUpperCase()
                              : '?',
                          style: AppTypography.displaySmall
                              .copyWith(color: AppColors.oliveGold),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.peach.withOpacity(0.3),
                      child: Text(
                        host.name.isNotEmpty ? host.name[0].toUpperCase() : '?',
                        style: AppTypography.displaySmall
                            .copyWith(color: AppColors.oliveGold),
                      ),
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    host.name,
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  if (host.isVerified)
                    Row(
                      children: [
                        const Icon(Icons.verified,
                            color: AppColors.forestGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Host',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.forestGreen),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Joined in ${host.memberSince.year}',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(Host host) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Host Rating', style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < host.avgHostRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: AppColors.oliveGold,
                    size: 28,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  host.avgHostRating.toStringAsFixed(1),
                  style: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(Host host) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About ${host.name}', style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            Text(
              host.about,
              style: AppTypography.bodyMedium.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesSection(Host host) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Text('Languages', style: AppTypography.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: host.languages
                  .map((lang) => Chip(
                        label: Text(lang),
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
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencesSection(Host host) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Experiences', style: AppTypography.titleSmall),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildExperienceCounter(
                      count: _hostExperiences.length,
                      label: 'Hosted',
                      color: AppColors.forestGreen,
                    ),
                    _buildExperienceCounter(
                      count: host.joinedExperiences,
                      label: 'Joined',
                      color: AppColors.oliveGold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingExperiences)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_hostExperiences.isEmpty)
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.explore_off,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No experiences yet',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'Hosted Experiences',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._hostExperiences.map((experience) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ExperienceCard(
                      experience: experience,
                      onTap: () => context.push('/experience/${experience.id}'),
                    ),
                  )),
            ],
          ),
      ],
    );
  }

  Widget _buildExperienceCounter(
      {required int count, required String label, required Color color}) {
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
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserId = user?.uid;
    final currentUserEmail = user?.email;
    final hostId = widget.hostId;

    // Robust host check: compare against both UID and Email
    // This handles cases where hostId might be an email address or a UID
    final isHost = currentUserId == hostId ||
        (currentUserEmail != null &&
            currentUserEmail.toLowerCase() == hostId.toLowerCase()) ||
        (currentUserEmail != null &&
            currentUserEmail.toLowerCase() == hostId);

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
        child: ElevatedButton.icon(
          onPressed: isHost
              ? null // Disable if viewing own profile
              : () => _messageHost(context),
          icon: const Icon(Icons.message_outlined),
          label: const Text('Message Host'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _messageHost(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to message the host')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final chatId = await ChatService().getOrCreateChat(widget.hostId);

      // Dismiss loading indicator
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              otherUserName: _host?.name ?? 'Host',
            ),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading indicator if open
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e')),
        );
      }
    }
  }
}
