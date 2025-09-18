import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../mock/mock_data.dart';

/// Filters bottom sheet for the discover screen
class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({
    super.key,
    required this.selectedCategories,
    required this.selectedRegions,
    required this.onApplyFilters,
  });

  final List<String> selectedCategories;
  final List<String> selectedRegions;
  final Function(List<String> categories, List<String> regions) onApplyFilters;

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late List<String> _selectedCategories;
  late List<String> _selectedRegions;
  late List<String> _selectedLanguages;
  double _maxPrice = 100.0;
  bool _sustainabilityOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedRegions = List.from(widget.selectedRegions);
    _selectedLanguages = [];
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
                    _buildSection(
                      'Region',
                      _buildChipsList(
                        MockData.regions,
                        _selectedRegions,
                        (region) => _toggleRegion(region),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    _buildSection(
                      'Category',
                      _buildChipsList(
                        MockData.categories,
                        _selectedCategories,
                        (category) => _toggleCategory(category),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Price range
                    _buildSection(
                      'Price Range',
                      _buildPriceSlider(),
                    ),

                    const SizedBox(height: 24),

                    // Languages
                    _buildSection(
                      'Languages',
                      _buildLanguageCheckboxes(),
                    ),

                    const SizedBox(height: 24),

                    // Sustainability
                    _buildSection(
                      'Sustainability',
                      _buildSustainabilityToggle(),
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
              '\$0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '\$${_maxPrice.round()}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.forestGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$200+',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxPrice,
          min: 0,
          max: 200,
          divisions: 20,
          onChanged: (value) {
            setState(() {
              _maxPrice = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLanguageCheckboxes() {
    return Column(
      children: MockData.availableLanguages.map((language) {
        final isSelected = _selectedLanguages.contains(language);
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
            language,
            style: AppTypography.bodyMedium,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildSustainabilityToggle() {
    return SwitchListTile(
      value: _sustainabilityOnly,
      onChanged: (value) {
        setState(() {
          _sustainabilityOnly = value;
        });
      },
      title: Text(
        'Sustainable experiences only',
        style: AppTypography.bodyMedium,
      ),
      subtitle: Text(
        'Show only eco-friendly and culturally responsible experiences',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      contentPadding: EdgeInsets.zero,
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
      _maxPrice = 100.0;
      _sustainabilityOnly = false;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_selectedCategories, _selectedRegions);
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
