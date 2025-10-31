import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' as services;
import '../../services/image_processing_service.dart';

/// Create experience screen with form for adding new experiences
class CreateExperienceScreen extends StatefulWidget {
  const CreateExperienceScreen({super.key});

  @override
  State<CreateExperienceScreen> createState() => _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends State<CreateExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _groupSizeController = TextEditingController();
  final _locationSearchController = TextEditingController();
  final _skillsToTeachController = TextEditingController();
  final _skillsToLearnController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedLanguages = [];
  List<String> _selectedPaymentOptions = [];
  List<String> _selectedAccessibilityFeatures = [];
  final List<String> _imageUrls = [];
  final List<File> _localPhotos = [];
  GeoPoint? _selectedGeoPoint;
  String? _selectedLocationLabel;
  String? _selectedDepartment;
  bool _isLoading = false;

  static const List<String> _languageOptions = ['es', 'en', 'pt', 'fr'];
  static const List<String> _paymentOptions = ['cash', 'card'];
  static const List<String> _accessibilityOptions = [
    'Wheelchair Access',
    'Elevator',
    'Accessible Parking',
    'Accessible Restroom',
    'Ramps',
    'Braille Signage',
    'Audio Guide',
    'Service Animals Allowed'
  ];
  static const String _placesApiKey = String.fromEnvironment(
      'GOOGLE_PLACES_API_KEY',
      defaultValue: 'AIzaSyA0TPkWq9uNvEA0Qhw2NVBihLbRTroYabE');

  // Google Places typeahead state
  List<Map<String, dynamic>> _placeSuggestions = [];
  bool _isFetchingPlaces = false;
  Timer? _placesDebounce;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _groupSizeController.dispose();
    _locationSearchController.dispose();
    _skillsToTeachController.dispose();
    _skillsToLearnController.dispose();
    _placesDebounce?.cancel();
    super.dispose();
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (hours)',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () {
                final v = int.tryParse(_durationController.text.trim()) ?? 0;
                final next = v - 1;
                _durationController.text = (next < 0 ? 0 : next).toString();
                setState(() {});
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  services.FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: const InputDecoration(
                  hintText: 'e.g. 3 (hours)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter duration in hours';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                    return 'Enter a valid non-negative integer';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              onPressed: () {
                final v = int.tryParse(_durationController.text.trim()) ?? 0;
                _durationController.text = (v + 1).toString();
                setState(() {});
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumericField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool allowNegative,
    required String validatorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            services.FilteringTextInputFormatter.allow(
              allowNegative ? RegExp(r'[-0-9]') : RegExp(r'[0-9]'),
            ),
          ],
          decoration: InputDecoration(
            hintText: hint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorMessage;
            }
            final ok = allowNegative
                ? RegExp(r'^-?\d+$').hasMatch(value.trim())
                : RegExp(r'^\d+$').hasMatch(value.trim());
            if (!ok) return validatorMessage;
            if (!allowNegative && int.tryParse(value.trim())! < 0) {
              return validatorMessage;
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Experience',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveExperience,
            child: Text(
              'Save',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo upload section
            _buildPhotoSection(),

            const SizedBox(height: 24),

            // Experience title
            _buildTextField(
              label: 'Experience Title',
              controller: _titleController,
              hint: 'e.g. Learn Coffee Harvesting & Teach Photography',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Description
            _buildTextField(
              label: 'Description',
              controller: _descriptionController,
              hint:
                  'Describe the experience and what guests will learn and teach...',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Category dropdown
            _buildCategoryMultiSelect(),

            const SizedBox(height: 20),

            // Duration (hours, non-negative)
            _buildDurationField(),

            const SizedBox(height: 20),

            // Department is auto-filled from location

            // Price (COP, non-negative)
            _buildNumericField(
              label: 'Price (COP)',
              controller: _priceController,
              hint: 'e.g. 120000',
              allowNegative: false,
              validatorMessage: 'Please enter a valid non-negative price',
            ),

            const SizedBox(height: 20),

            // Group size (non-negative)
            _buildNumericField(
              label: 'Max Group Size',
              controller: _groupSizeController,
              hint: 'e.g. 8',
              allowNegative: false,
              validatorMessage: 'Please enter a valid non-negative group size',
            ),

            const SizedBox(height: 20),

            // Location picker with Google Places search
            _buildLocationPicker(),

            const SizedBox(height: 20),

            // Skills you will teach
            _buildTextField(
              label: 'Skills You Will Teach',
              controller: _skillsToTeachController,
              hint:
                  'What skills or knowledge will you share with participants?',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter skills you will teach';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Skills you want to learn
            _buildTextField(
              label: 'Skills You Want to Learn',
              controller: _skillsToLearnController,
              hint: 'What would you like to learn from participants?',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter skills you want to learn';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Languages
            _buildChipsSection(
              label: 'Languages',
              options: _languageOptions,
              selected: _selectedLanguages,
              onToggle: (value) {
                setState(() {
                  if (_selectedLanguages.contains(value)) {
                    _selectedLanguages.remove(value);
                  } else {
                    _selectedLanguages.add(value);
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            // Payment Options
            _buildChipsSection(
              label: 'Payment Options',
              options: _paymentOptions,
              selected: _selectedPaymentOptions,
              onToggle: (value) {
                setState(() {
                  if (_selectedPaymentOptions.contains(value)) {
                    _selectedPaymentOptions.remove(value);
                  } else {
                    _selectedPaymentOptions.add(value);
                  }
                });
              },
            ),

            const SizedBox(height: 20),

            // Accessibility Features
            _buildChipsSection(
              label: 'Accessibility Features',
              options: _accessibilityOptions,
              selected: _selectedAccessibilityFeatures,
              onToggle: (value) {
                setState(() {
                  if (_selectedAccessibilityFeatures.contains(value)) {
                    _selectedAccessibilityFeatures.remove(value);
                  } else {
                    _selectedAccessibilityFeatures.add(value);
                  }
                });
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index < _localPhotos.length) {
                final file = _localPhotos[index];
                return AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deletePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.lava,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildPhotoPlaceholder('Add Photo');
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: (_localPhotos.length + 1).clamp(1, 8),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(String label) {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: AppColors.divider,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.forestGreen, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Removed old dropdown; replaced by multi-select

  Widget _buildCategoryMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MockData.categories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChipsSection({
    required String label,
    required List<String> options,
    required List<String> selected,
    required void Function(String value) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt);
            return FilterChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onToggle(opt),
            );
          }).toList(),
        ),
      ],
    );
  }

  // removed image URLs manual input; URLs are added automatically after upload

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _locationSearchController,
          decoration: InputDecoration(
            hintText: 'Search a place',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.place_outlined),
              onPressed: () => _openPlacesSearch(),
            ),
          ),
          onChanged: _onPlaceQueryChanged,
        ),
        const SizedBox(height: 8),
        if (_isFetchingPlaces) const LinearProgressIndicator(minHeight: 2),
        if (_placeSuggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _placeSuggestions.length,
              itemBuilder: (context, index) {
                final s = _placeSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    (s['description'] as String?) ?? '',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () async {
                    final placeId = s['place_id'] as String?;
                    if (placeId != null) {
                      final details = await _fetchPlaceDetails(placeId);
                      if (!mounted) return;
                      setState(() {
                        _selectedGeoPoint = GeoPoint(
                            (details['lat'] as num).toDouble(),
                            (details['lng'] as num).toDouble());
                        _selectedLocationLabel = s['description'] as String?;
                        _locationSearchController.text =
                            _selectedLocationLabel ?? '';
                        _selectedDepartment = details['department'] as String?;
                        _placeSuggestions = [];
                      });
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _onPlaceQueryChanged(String value) {
    _placesDebounce?.cancel();
    if (_placesApiKey.isEmpty) return;
    if (value.trim().isEmpty) {
      setState(() {
        _placeSuggestions = [];
      });
      return;
    }
    _placesDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _isFetchingPlaces = true;
      });
      final results = await _fetchPlaceSuggestions(value.trim());
      if (!mounted) return;
      setState(() {
        _placeSuggestions = results;
        _isFetchingPlaces = false;
      });
    });
  }

  Future<void> _openPlacesSearch() async {
    if (_placesApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Provide GOOGLE_PLACES_API_KEY to enable place search',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.lava,
        ),
      );
      return;
    }
    final input = _locationSearchController.text.trim();
    if (input.isEmpty) return;

    final suggestions = await _fetchPlaceSuggestions(input);
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: suggestions
            .map((s) => ListTile(
                  title: Text(
                    s['description'] as String? ?? '',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () async {
                    final placeId = s['place_id'] as String?;
                    if (placeId != null) {
                      final details = await _fetchPlaceDetails(placeId);
                      if (!mounted) return;
                      setState(() {
                        _selectedGeoPoint =
                            GeoPoint(details['lat']!, details['lng']!);
                        _selectedLocationLabel = s['description'] as String?;
                        _locationSearchController.text =
                            _selectedLocationLabel ?? '';
                        _placeSuggestions = [];
                      });
                    }
                    if (mounted) Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPlaceSuggestions(
      String input) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeQueryComponent(input)}&types=geocode&key=$_placesApiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body) as Map<String, dynamic>;
    final preds = (data['predictions'] as List? ?? []).cast<Map>();
    return preds.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> _fetchPlaceDetails(String placeId) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,address_components&key=$_placesApiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200)
      return {'lat': 0.0, 'lng': 0.0, 'department': null};
    final data = json.decode(res.body) as Map<String, dynamic>;
    final result = (data['result'] as Map?) ?? {};
    final loc = ((result['geometry'] as Map?)?['location'] as Map?) ?? {};
    final comps = (result['address_components'] as List?)?.cast<Map>() ?? [];
    String? admin1;
    for (final c in comps) {
      final types = (c['types'] as List?)?.cast<String>() ?? [];
      if (types.contains('administrative_area_level_1')) {
        admin1 = c['long_name'] as String?;
        break;
      }
    }
    return {
      'lat': (loc['lat'] as num?)?.toDouble() ?? 0.0,
      'lng': (loc['lng'] as num?)?.toDouble() ?? 0.0,
      'department': admin1,
    };
  }

  void _addPhoto() {
    _pickAndUploadFromCamera();
  }

  void _deletePhoto(int index) {
    if (index < 0 || index >= _localPhotos.length) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Photo',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this photo?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
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
            onPressed: () {
              setState(() {
                _localPhotos.removeAt(index);
                _imageUrls.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Photo deleted',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.forestGreen,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Delete',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.lava,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? captured = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 85);
      if (captured == null) return;

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Compressing image...',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.forestGreen,
          duration: const Duration(seconds: 10),
        ),
      );

      // ✅ Compress image in separate isolate (multi-threading)
      // This runs on a separate thread and won't block the UI
      final compressedBytes = await ImageProcessingService.compressImage(
        imagePath: captured.path,
        maxWidth: 1920,
        quality: 85,
      );

      // Upload to Firebase Storage under user ID folder
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      final String uid = user.uid;
      final String fileName =
          'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File file = File(captured.path);

      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://travelappbd-8e204.firebasestorage.app',
      );
      final ref = storage.ref().child('experiences/$uid/$fileName');
      
      // Upload compressed bytes instead of raw file
      final uploadTask = await ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      if (!mounted) return;
      
      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      setState(() {
        _localPhotos.add(file);
        _imageUrls.add(downloadUrl);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo added successfully',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.forestGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: AppColors.lava,
        ),
      );
    }
  }

  void _saveExperience() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedGeoPoint == null) {
        throw Exception('Please pick a location');
      }
      if (_selectedCategories.isEmpty) {
        throw Exception('Please select at least one category');
      }
      if (_selectedLanguages.isEmpty) {
        throw Exception('Please select at least one language');
      }
      if (_selectedPaymentOptions.isEmpty) {
        throw Exception('Please select at least one payment option');
      }
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('No authenticated user');
      }

      final hostDocId = (authUser.email ?? '').toLowerCase().isNotEmpty
          ? (authUser.email ?? '').toLowerCase()
          : authUser.uid;
      final hostRef =
          FirebaseFirestore.instance.collection('users').doc(hostDocId);
      final hostSnap = await hostRef.get();
      final hostData = hostSnap.data() ?? <String, dynamic>{};

      final String title = _titleController.text.trim();
      final String summary = _descriptionController.text.trim();
      final String department = _selectedDepartment ?? '';
      final int duration = int.tryParse(_durationController.text.trim()) ?? 0;
      final List<String> categories =
          _selectedCategories.map((c) => c.toLowerCase()).toList();
      final List<String> skillsToTeach = _skillsToTeachController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> skillsToLearn = _skillsToLearnController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final int price = int.tryParse(_priceController.text.trim()) ?? 0;
      final int groupSizeMax =
          int.tryParse(_groupSizeController.text.trim()) ?? 0;

      final Map<String, dynamic> experience = {
        'title': title,
        'summary': summary,
        'categories': categories,
        'department': department,
        'duration': duration,
        'hostId': hostRef,
        'hostVerified': (hostData['isVerified'] ?? false) as bool,
        'avgRating': 0,
        'reviewsCount': 0,
        'groupSizeMax': groupSizeMax,
        'priceCOP': price,
        'paymentOptions': _selectedPaymentOptions,
        'languages': _selectedLanguages,
        'images': _imageUrls,
        'isActive': true,
        'accessibilityFeatures': _selectedAccessibilityFeatures,
        'location': _selectedGeoPoint,
        'skillsToTeach': skillsToTeach.isEmpty
            ? <String>[_skillsToTeachController.text.trim()]
                .where((e) => e.isNotEmpty)
                .toList()
            : skillsToTeach,
        'skillsToLearn': skillsToLearn.isEmpty
            ? <String>[_skillsToLearnController.text.trim()]
                .where((e) => e.isNotEmpty)
                .toList()
            : skillsToLearn,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('experiences')
          .add(experience);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to My Experiences screen
      context.go('/my-experiences');

      // Show success message after navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Experience created successfully!',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.forestGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create experience: $e',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.lava,
        ),
      );
    }
  }
}
