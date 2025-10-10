import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, sin, atan2, pi;
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/experience_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
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
  List<Experience> _allExperiences = [];
  List<Experience> _filteredExperiences = [];
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<String> _selectedRegions = [];
  List<String> _selectedLanguages = [];
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  final ExperienceService _experienceService = ExperienceService();
  bool _isLoading = true;

  // Location services
  final Location _location = Location();
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    await _initializeLocation();
    await _fetchExperiences();
  }

  /// Initialize location services and get current location
  Future<void> _initializeLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      // Check location permissions
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      // Get current location
      _currentLocation = await _location.getLocation();
    } catch (e) {
      debugPrint('Error initializing location: $e');
      // Optionally show a message to the user
    }
  }

  Future<void> _fetchExperiences() async {
    try {
      final experiences = await _experienceService.getExperiences();
      setState(() {
        _allExperiences = experiences;
        _filterExperiences(); // This will also handle initial sorting
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, maybe show a snackbar
    }
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildExperienceList(),
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

  void _filterExperiences() {
    List<Experience> experiences = _allExperiences;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      experiences = experiences
          .where((exp) =>
              exp.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              exp.summary.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (_selectedCategories.isNotEmpty) {
      experiences = experiences
          .where((exp) =>
              exp.categories.any((cat) => _selectedCategories.contains(cat)))
          .toList();
    }

    // Filter by region (department)
    if (_selectedRegions.isNotEmpty) {
      experiences = experiences
          .where((exp) => _selectedRegions.contains(exp.department))
          .toList();
    }

    // Filter by price range
    if (_minPrice > 0 || _maxPrice < double.infinity) {
      experiences = experiences
          .where(
              (exp) => exp.priceCOP >= _minPrice && exp.priceCOP <= _maxPrice)
          .toList();
    }

    // Filter by languages
    if (_selectedLanguages.isNotEmpty) {
      experiences = experiences
          .where((exp) =>
              exp.languages.any((lang) => _selectedLanguages.contains(lang)))
          .toList();
    }

    // Sort by distance if location is available
    if (_currentLocation != null) {
      experiences.sort((a, b) {
        final distanceA = _calculateHaversineDistance(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
          a.location.latitude,
          a.location.longitude,
        );
        final distanceB = _calculateHaversineDistance(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
          b.location.latitude,
          b.location.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
    }

    // NOTE: Region filtering is not implemented as it's not in the new model

    setState(() {
      _filteredExperiences = experiences;
    });
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _filterExperiences();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filterExperiences();
    });
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategories.clear();
      _selectedRegions.clear();
      _selectedLanguages.clear();
      _minPrice = 0;
      _maxPrice = double.infinity;
      _filterExperiences();
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
        selectedLanguages: _selectedLanguages,
        minPrice: _minPrice,
        maxPrice: _maxPrice == double.infinity ? 0 : _maxPrice,
        allExperiences: _allExperiences,
        onApplyFilters: (categories, regions, languages, minPrice, maxPrice) {
          setState(() {
            _selectedCategories = categories;
            _selectedRegions = regions;
            _selectedLanguages = languages;
            _minPrice = minPrice;
            _maxPrice = maxPrice == 0 ? double.infinity : maxPrice;
            _filterExperiences();
          });
        },
      ),
    );
  }

  // Method to update price range filter
  void updatePriceRange(double minPrice, double maxPrice) {
    setState(() {
      _minPrice = minPrice;
      _maxPrice = maxPrice;
      _filterExperiences();
    });
  }

  // Method to update languages filter
  void updateLanguages(List<String> languages) {
    setState(() {
      _selectedLanguages = languages;
      _filterExperiences();
    });
  }

  void _navigateToChatbot() {
    context.push('/chatbot');
  }

  void _navigateToExperience(String experienceId) {
    context.push('/experience/$experienceId');
  }

  /// Calculates the distance between two coordinates using the Haversine formula.
  double _calculateHaversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
