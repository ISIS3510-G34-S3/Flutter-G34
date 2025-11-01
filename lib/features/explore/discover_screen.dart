import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/experience_card.dart';
import '../../widgets/filters_bottom_sheet.dart';
import 'discover_view_model.dart';

/// Discover screen with search, filters, and experience listings
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  late DiscoverViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DiscoverViewModel();
    _viewModel.initialize();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🏗️ DiscoverScreen build called - experiences: ${_viewModel.filteredExperiences.length}, isLoading: ${_viewModel.isLoading}, isRefreshing: ${_viewModel.isRefreshing}');

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Connectivity status banner
            if (!_viewModel.isOnline)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.oliveGold.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 16,
                      color: AppColors.oliveGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No internet connection - using offline data',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.oliveGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Search and filters section
            _buildSearchSection(),

            // Experience list
            Expanded(
              child: _viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildExperienceList(),
            ),
          ],
        ),
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
              suffixIcon: _viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.clearSearch();
                      },
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
            onChanged: (value) => _viewModel.updateSearchQuery(value),
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

              // Travel Agent button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateToChatbot,
                  icon: const Icon(Icons.support_agent),
                  label: Text(
                    'Travel Agent',
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
    debugPrint(
        '🏗️ Building experience list with ${_viewModel.filteredExperiences.length} items');

    if (_viewModel.filteredExperiences.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        debugPrint('👆 User pulled down to refresh');
        await _viewModel.fetchExperiences(forceRefresh: true);
        debugPrint('✅ Refresh completed');
      },
      color: AppColors.forestGreen,
      child: ListView.builder(
        key: ObjectKey(_viewModel.filteredExperiences),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _viewModel.filteredExperiences.length,
        itemBuilder: (context, index) {
          final experience = _viewModel.filteredExperiences[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ExperienceCard(
              key: ValueKey('exp_${experience.id}'),
              experience: experience,
              onTap: () => _navigateToExperience(experience.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    // Check if we have no data and are offline
    final bool hasNoDataAndOffline =
        _viewModel.allExperiences.isEmpty && !_viewModel.isOnline;

    // Check if filters are active
    final bool hasActiveFilters = _viewModel.searchQuery.isNotEmpty ||
        _viewModel.selectedCategories.isNotEmpty ||
        _viewModel.selectedRegions.isNotEmpty ||
        _viewModel.selectedLanguages.isNotEmpty ||
        _viewModel.minPrice > 0 ||
        _viewModel.maxPrice < double.infinity;

    return RefreshIndicator(
      onRefresh: () async {
        debugPrint('👆 User pulled down to refresh (empty state)');
        await _viewModel.fetchExperiences(forceRefresh: true);
        debugPrint('✅ Refresh completed (empty state)');
      },
      color: AppColors.forestGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
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
                    child: Icon(
                      hasNoDataAndOffline ? Icons.cloud_off : Icons.search_off,
                      size: 40,
                      color: AppColors.oliveGold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    hasNoDataAndOffline
                        ? 'No cached data available'
                        : 'No experiences found',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasNoDataAndOffline
                        ? 'You\'re offline and no cached experiences are available. Please connect to the internet to load experiences.'
                        : hasActiveFilters
                            ? 'Try adjusting your search or filters to find more experiences.'
                            : 'Pull down to refresh or check your internet connection.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (hasActiveFilters && !hasNoDataAndOffline)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.clearAllFilters();
                        FocusScope.of(context).unfocus();
                      },
                      child: Text(
                        'Clear all filters',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  if (hasNoDataAndOffline)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _viewModel.fetchExperiences(forceRefresh: true);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FiltersBottomSheet(
        selectedCategories: _viewModel.selectedCategories,
        selectedRegions: _viewModel.selectedRegions,
        selectedLanguages: _viewModel.selectedLanguages,
        minPrice: _viewModel.minPrice,
        maxPrice:
            _viewModel.maxPrice == double.infinity ? 0 : _viewModel.maxPrice,
        allExperiences: _viewModel.allExperiences,
        onApplyFilters: (categories, regions, languages, minPrice, maxPrice) {
          _viewModel.applyFilters(
            categories: categories,
            regions: regions,
            languages: languages,
            minPrice: minPrice,
            maxPrice: maxPrice,
          );
        },
      ),
    );
  }

  void _navigateToChatbot() {
    // Check if online before navigating to chatbot
    if (!_viewModel.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                    'No internet connection. The Travel Agent requires internet access.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    context.push('/chatbot');
  }

  void _navigateToExperience(String experienceId) {
    context.push('/experience/$experienceId');
  }
}
