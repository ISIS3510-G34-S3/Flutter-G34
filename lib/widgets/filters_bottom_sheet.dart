import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/experience.dart';

/// Filters bottom sheet for the discover screen
class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({
    super.key,
    required this.selectedCategories,
    required this.selectedRegions,
    required this.selectedLanguages,
    required this.minPrice,
    required this.maxPrice,
    required this.onApplyFilters,
    required this.allExperiences,
  });

  final List<String> selectedCategories;
  final List<String> selectedRegions;
  final List<String> selectedLanguages;
  final double minPrice;
  final double maxPrice;
  final Function(List<String> categories, List<String> regions,
      List<String> languages, double minPrice, double maxPrice) onApplyFilters;
  final List<Experience> allExperiences;

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

/// Helper function to convert language codes to display names
String _getLanguageDisplayName(String langCode) {
  final languageMap = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ru': 'Русский',
  };
  return languageMap[langCode.toLowerCase()] ?? langCode;
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late List<String> _selectedCategories;
  late List<String> _selectedRegions;
  late List<String> _selectedLanguages;
  double _maxPrice = 100.0;

  // Dynamic filter options extracted from actual data
  List<String> _availableCategories = [];
  List<String> _availableRegions = [];
  List<String> _availableLanguages = [];
  double _minPriceInData = 0;
  double _maxPriceInData = 200.0;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedRegions = List.from(widget.selectedRegions);
    _selectedLanguages = List.from(widget.selectedLanguages);
    _maxPrice = widget.maxPrice > 0 ? widget.maxPrice : 100.0;
    _extractFilterOptions();
  }

  /// Extract available filter options from the actual experiences data
  void _extractFilterOptions() {
    if (widget.allExperiences.isEmpty) return;

    // Extract unique categories
    final categoriesSet = <String>{};
    for (var exp in widget.allExperiences) {
      categoriesSet.addAll(exp.categories);
    }
    _availableCategories = categoriesSet.toList()..sort();

    // Extract unique regions (departments)
    final regionsSet = <String>{};
    for (var exp in widget.allExperiences) {
      if (exp.department.isNotEmpty) {
        regionsSet.add(exp.department);
      }
    }
    _availableRegions = regionsSet.toList()..sort();

    // Extract unique languages
    final languagesSet = <String>{};
    for (var exp in widget.allExperiences) {
      languagesSet.addAll(exp.languages);
    }
    _availableLanguages = languagesSet.toList()..sort();

    // Calculate price range from data
    final prices =
        widget.allExperiences.map((e) => e.priceCOP.toDouble()).toList();
    if (prices.isNotEmpty) {
      _minPriceInData = prices.reduce((a, b) => a < b ? a : b);
      _maxPriceInData = prices.reduce((a, b) => a > b ? a : b);

      // Round max price to nearest 50000
      _maxPriceInData = ((_maxPriceInData / 50000).ceil() * 50000).toDouble();

      // Update initial max price if it was default
      if (_maxPrice == 100.0) {
        _maxPrice = _maxPriceInData;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(
                        'Reset',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filter content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Regions
                    if (_availableRegions.isNotEmpty)
                      _buildSection(
                        'Region',
                        _buildChipsList(
                          _availableRegions,
                          _selectedRegions,
                          (region) => _toggleRegion(region),
                        ),
                      ),

                    if (_availableRegions.isNotEmpty)
                      const SizedBox(height: 24),

                    // Categories
                    if (_availableCategories.isNotEmpty)
                      _buildSection(
                        'Category',
                        _buildChipsList(
                          _availableCategories,
                          _selectedCategories,
                          (category) => _toggleCategory(category),
                        ),
                      ),

                    if (_availableCategories.isNotEmpty)
                      const SizedBox(height: 24),

                    // Price range
                    _buildSection(
                      'Price Range',
                      _buildPriceSlider(),
                    ),

                    const SizedBox(height: 24),

                    // Languages
                    if (_availableLanguages.isNotEmpty)
                      _buildSection(
                        'Languages',
                        _buildLanguageCheckboxes(),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Action buttons
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildChipsList(
    List<String> items,
    List<String> selectedItems,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return FilterChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => onToggle(item),
          backgroundColor: AppColors.peach.withValues(alpha: 0.3),
          selectedColor: AppColors.oliveGold,
          checkmarkColor: AppColors.white,
          labelStyle: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? AppColors.oliveGold : AppColors.divider,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_formatPrice(_minPriceInData)}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '\$${_formatPrice(_maxPrice)}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.forestGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${_formatPrice(_maxPriceInData)}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxPrice.clamp(_minPriceInData, _maxPriceInData),
          min: _minPriceInData,
          max: _maxPriceInData,
          divisions: ((_maxPriceInData - _minPriceInData) / 10000)
              .round()
              .clamp(1, 100),
          onChanged: (value) {
            setState(() {
              _maxPrice = value;
            });
          },
        ),
      ],
    );
  }

  /// Format price for display (e.g., 150000 -> 150K)
  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }

  Widget _buildLanguageCheckboxes() {
    if (_availableLanguages.isEmpty) {
      return Text(
        'No languages available',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: _availableLanguages.map((language) {
        final isSelected = _selectedLanguages.contains(language);
        final displayName = _getLanguageDisplayName(language);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedLanguages.add(language);
              } else {
                _selectedLanguages.remove(language);
              }
            });
          },
          title: Text(
            displayName,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _toggleRegion(String region) {
    setState(() {
      if (_selectedRegions.contains(region)) {
        _selectedRegions.remove(region);
      } else {
        _selectedRegions.add(region);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedRegions.clear();
      _selectedLanguages.clear();
      _maxPrice = _maxPriceInData;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_selectedCategories, _selectedRegions,
        _selectedLanguages, 0.0, _maxPrice);
    Navigator.of(context).pop();

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Filters applied successfully',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
