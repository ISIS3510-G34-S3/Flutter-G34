import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, sin, atan2, pi;
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/experience_service.dart';

class DiscoverViewModel extends ChangeNotifier {
  // Services
  final ExperienceService _experienceService = ExperienceService();
  final Location _location = Location();

  // State
  List<Experience> _allExperiences = [];
  List<Experience> _filteredExperiences = [];
  LocationData? _currentLocation;
  bool _isLoading = true;
  
  // Filter state
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<String> _selectedRegions = [];
  List<String> _selectedLanguages = [];
  double _minPrice = 0;
  double _maxPrice = double.infinity;

  // Getters
  List<Experience> get allExperiences => _allExperiences;
  List<Experience> get filteredExperiences => _filteredExperiences;
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedRegions => _selectedRegions;
  List<String> get selectedLanguages => _selectedLanguages;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  /// Initialize location and fetch experiences
  Future<void> initialize() async {
    await _initializeLocation();
    await fetchExperiences();
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
    }
  }

  /// Fetch experiences from service
  Future<void> fetchExperiences() async {
    try {
      final experiences = await _experienceService.getExperiences();
      _allExperiences = experiences;
      _filterExperiences();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching experiences: $e');
    }
  }

  /// Filter and sort experiences based on current filter state
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

    _filteredExperiences = experiences;
  }

  /// Update search query and filter
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterExperiences();
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    _filterExperiences();
    notifyListeners();
  }

  /// Apply filters from filter bottom sheet
  void applyFilters({
    required List<String> categories,
    required List<String> regions,
    required List<String> languages,
    required double minPrice,
    required double maxPrice,
  }) {
    _selectedCategories = categories;
    _selectedRegions = regions;
    _selectedLanguages = languages;
    _minPrice = minPrice;
    _maxPrice = maxPrice == 0 ? double.infinity : maxPrice;
    _filterExperiences();
    notifyListeners();
  }

  /// Clear all filters
  void clearAllFilters() {
    _searchQuery = '';
    _selectedCategories.clear();
    _selectedRegions.clear();
    _selectedLanguages.clear();
    _minPrice = 0;
    _maxPrice = double.infinity;
    _filterExperiences();
    notifyListeners();
  }

  /// Update price range filter
  void updatePriceRange(double minPrice, double maxPrice) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _filterExperiences();
    notifyListeners();
  }

  /// Update languages filter
  void updateLanguages(List<String> languages) {
    _selectedLanguages = languages;
    _filterExperiences();
    notifyListeners();
  }

  /// Calculates the distance between two coordinates using the Haversine formula
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