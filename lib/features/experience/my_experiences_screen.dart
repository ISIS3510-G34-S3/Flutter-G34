import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/experience_service.dart';
import 'package:travel_connect/theme/colors.dart';
import 'package:travel_connect/theme/typography.dart';

class MyExperiencesScreen extends StatefulWidget {
  const MyExperiencesScreen({super.key});

  @override
  State<MyExperiencesScreen> createState() => _MyExperiencesScreenState();
}

class _MyExperiencesScreenState extends State<MyExperiencesScreen> {
  final ExperienceService _service = ExperienceService();

  Future<void> _confirmDelete(BuildContext context, Experience exp) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete experience'),
        content: Text('Are you sure you want to delete "${exp.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _service.deleteExperienceAndImages(exp.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deleted',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.forestGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete: $e',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.lava,
          ),
        );
      }
    }
  }

  void _openCreate() {
    context.go('/create');
  }

  void _openDetail(String id) {
    context.push('/experience/$id');
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My experiences',
          style: AppTypography.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        actions: [
          IconButton(
            onPressed: _openCreate,
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create',
          )
        ],
      ),
      body: StreamBuilder<List<Experience>>(
        stream: _service.watchMyExperiences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final experiences = snapshot.data ?? const <Experience>[];
          if (experiences.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.post_add_outlined, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      'You have not created any experiences yet',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _openCreate,
                      child: const Text('Create experience'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: experiences.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final exp = experiences[index];
              return ListTile(
                onTap: () => _openDetail(exp.id),
                leading: CircleAvatar(
                  backgroundColor: AppColors.forestGreen.withOpacity(0.1),
                  child: const Icon(Icons.explore_outlined, color: AppColors.forestGreen),
                ),
                title: Text(exp.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  exp.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => context.push('/experience/${exp.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, exp),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


