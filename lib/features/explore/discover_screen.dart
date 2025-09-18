import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';
import '../../widgets/experience_card.dart';
import '../../widgets/filters_bottom_sheet.dart';

/// Discover screen with search, filters, and experience listings
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  List<Experience> _filteredExperiences = MockData.experiences;
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<String> _selectedRegions = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search and filters section
          _buildSearchSection(),

          // Experience list
          Expanded(
            child: _buildExperienceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search experiences...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.forestGreen, width: 2),
              ),
            ),
            onChanged: _handleSearchChanged,
          ),

          const SizedBox(height: 16),

          // Action buttons row
          Row(
            children: [
              // Filters button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune),
                  label: Text(
                    'Filters',
                    style: AppTypography.buttonMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Map view button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateToMap,
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    'Map View',
                    style: AppTypography.buttonMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceList() {
    if (_filteredExperiences.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredExperiences.length,
      itemBuilder: (context, index) {
        final experience = _filteredExperiences[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ExperienceCard(
            experience: experience,
            onTap: () => _navigateToExperience(experience.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.peach.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 40,
                color: AppColors.oliveGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No experiences found',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters to find more experiences.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                'Clear all filters',
                style: AppTypography.buttonMedium.copyWith(
                  color: AppColors.forestGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applyFilters();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredExperiences = MockData.filterExperiences(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        categories: _selectedCategories.isNotEmpty ? _selectedCategories : null,
        regions: _selectedRegions.isNotEmpty ? _selectedRegions : null,
      );
    });
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategories.clear();
      _selectedRegions.clear();
      _filteredExperiences = MockData.experiences;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FiltersBottomSheet(
        selectedCategories: _selectedCategories,
        selectedRegions: _selectedRegions,
        onApplyFilters: (categories, regions) {
          setState(() {
            _selectedCategories = categories;
            _selectedRegions = regions;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _navigateToMap() {
    context.go('/map');
  }

  void _navigateToExperience(String experienceId) {
    context.push('/experience/$experienceId');
  }
}
