import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../mock/mock_data.dart';
import '../../services/image_processing_service.dart';
import '../../services/experience_service.dart';
import '../../services/host_preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' as services;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Create experience screen with form for adding new experiences
class CreateExperienceScreen extends StatefulWidget {
  const CreateExperienceScreen({super.key});

  @override
  State<CreateExperienceScreen> createState() => _CreateExperienceScreenState();
}

class _CreateExperienceScreenState extends State<CreateExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExperienceService _experienceService = ExperienceService();
  final HostPreferencesService _hostPrefs = HostPreferencesService();
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
  String? _manualLocation;
  bool _hasConnectivity = true;

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
  void initState() {
    super.initState();
    // Start monitoring connectivity for auto-sync
    _experienceService.startConnectivityMonitoring();
    _loadPreferredLanguages();
    _checkInitialConnectivity();
    _listenToConnectivity();
  }

  void _checkInitialConnectivity() async {
    final hasInternet = await _experienceService.hasConnectivity();
    if (mounted) {
      setState(() {
        _hasConnectivity = hasInternet;
      });
    }
  }

  void _listenToConnectivity() {
    _experienceService.connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _hasConnectivity = isConnected;
        });
      }
    });
  }

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

  Future<void> _loadPreferredLanguages() async {
    final saved = await _hostPrefs.loadLanguages();
    if (!mounted) return;
    if (saved.isNotEmpty && _selectedLanguages.isEmpty) {
      setState(() {
        _selectedLanguages = List<String>.from(saved);
      });
    }
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
              // Always show the "Add Photo" button first
              if (index == 0) {
                return _buildPhotoPlaceholder('Add\nPhoto');
              }
              // Then show uploaded media
              if (index - 1 < _localPhotos.length) {
                final file = _localPhotos[index - 1];
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index - 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: _localPhotos.length + 1,
          ),
        ),
      ],
    );
  }

  void _removeMedia(int index) {
    setState(() {
      if (index < _localPhotos.length) {
        _localPhotos.removeAt(index);
      }
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      }
    });
  }

  Widget _buildPhotoPlaceholder(String label) {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        width: 120,
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
              textAlign: TextAlign.center,
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
    // Use manual mode when offline or no API key
    final useManualMode = !_hasConnectivity || _placesApiKey.isEmpty;
    
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
        TextFormField(
          controller: _locationSearchController,
          decoration: InputDecoration(
            hintText: useManualMode 
                ? 'Enter location (e.g., Salento, Quindío)'
                : 'Search a place',
            prefixIcon: Icon(useManualMode ? Icons.edit_location : Icons.search),
          ),
          onChanged: (value) {
            if (useManualMode) {
              setState(() {
                _manualLocation = value.trim();
              });
            } else {
              _onPlaceQueryChanged(value);
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        if (!useManualMode && _isFetchingPlaces) 
          const LinearProgressIndicator(minHeight: 2),
        if (!useManualMode && _placeSuggestions.isNotEmpty)
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
                        _manualLocation = null; // Clear manual mode
                      });
                    }
                  },
                );
              },
            ),
          ),
        if (useManualMode)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Enter location as text. GPS coordinates will be added when synced.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
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
    _showMediaSourceDialog();
  }

  /// Show dialog to choose between camera and gallery
  Future<void> _showMediaSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            'Add Photo',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withOpacity(0.1),
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
                  _pickAndUploadFromCamera();
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.oliveGold.withOpacity(0.1),
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
                  _pickAndUploadFromGallery();
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

  Future<void> _pickAndUploadFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? captured = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 85);
      if (captured == null) return;

      await _saveAndUploadMedia(captured, isVideo: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: $e'),
          backgroundColor: AppColors.lava,
        ),
      );
    }
  }

  Future<void> _pickAndUploadFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      await _saveAndUploadMedia(picked, isVideo: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.lava,
        ),
      );
    }
  }

  /// Save media locally and upload to Firebase Storage
  Future<void> _saveAndUploadMedia(XFile mediaFile,
      {required bool isVideo}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Save to Pictures/Travel Connect directory for easy user access
      Directory? picturesDir;
      if (Platform.isAndroid) {
        // On Android, use external storage Pictures directory
        final externalDirs = await getExternalStorageDirectories(
            type: StorageDirectory.pictures);
        if (externalDirs != null && externalDirs.isNotEmpty) {
          // Use public Pictures directory
          final basePath = externalDirs.first.path.split('/Android')[0];
          picturesDir = Directory('$basePath/Pictures/Travel Connect');
        }
      } else if (Platform.isIOS) {
        // On iOS, use app's documents directory (photos saved here can be accessed via Files app)
        final appDir = await getApplicationDocumentsDirectory();
        picturesDir = Directory('${appDir.path}/Travel Connect');
      } else {
        // Fallback for other platforms
        final appDir = await getApplicationDocumentsDirectory();
        picturesDir = Directory('${appDir.path}/Travel Connect');
      }

      if (picturesDir == null) {
        throw Exception('Could not find storage directory');
      }

      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      final String uid = user.uid;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = 'jpg';
      final String fileName = 'photo_$timestamp.$extension';

      // ✅ Compress image in separate isolate (multi-threading)
      final compressedBytes = await ImageProcessingService.compressImage(
        imagePath: mediaFile.path,
        maxWidth: 1920,
        quality: 85,
      );

      // Copy to local storage
      final localPath = '${picturesDir.path}/$fileName';
      final File localFile = File(localPath);
      await localFile.writeAsBytes(compressedBytes);

      // Check connectivity before uploading to Firebase
      final hasInternet = await _experienceService.hasConnectivity();

      if (hasInternet) {
        try {
          // Upload to Firebase Storage
          final storage = FirebaseStorage.instanceFor(
            bucket: 'gs://travelappbd-8e204.firebasestorage.app',
          );
          final ref = storage.ref().child('experiences/$uid/$fileName');
          final uploadTask = await ref.putData(
            compressedBytes,
            SettableMetadata(contentType: isVideo ? 'video/mp4' : 'image/jpeg'),
          );
          final String downloadUrl = await uploadTask.ref.getDownloadURL();

          if (!mounted) return;
          setState(() {
            _localPhotos.add(localFile);
            _imageUrls.add(downloadUrl);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isVideo
                    ? 'Video saved locally and uploaded!'
                    : 'Photo saved locally and uploaded!',
              ),
              backgroundColor: AppColors.forestGreen,
            ),
          );
        } catch (e) {
          print('⚠️ Failed to upload to Firebase, saving locally only: $e');
          // If upload fails, save locally only (handled below)
          if (!mounted) return;
          setState(() {
            _localPhotos.add(localFile);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isVideo
                    ? 'Video saved locally (offline)'
                    : 'Photo saved locally (offline)',
              ),
              backgroundColor: AppColors.oliveGold,
            ),
          );
        }
      } else {
        // No internet - save locally only
        if (!mounted) return;
        setState(() {
          _localPhotos.add(localFile);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVideo
                  ? 'Video saved locally (offline)'
                  : 'Photo saved locally (offline)',
            ),
            backgroundColor: AppColors.oliveGold,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save ${isVideo ? 'video' : 'photo'}: $e'),
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
      // Validate location
      if (_selectedGeoPoint == null && 
          (_manualLocation == null || _manualLocation!.isEmpty) &&
          _locationSearchController.text.trim().isEmpty) {
        throw Exception('Please enter a location');
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
      
      // Fetch host data only if online
      Map<String, dynamic> hostData = {'isVerified': false}; // Default
      if (_hasConnectivity) {
        try {
          final hostRef =
              FirebaseFirestore.instance.collection('users').doc(hostDocId);
          final hostSnap = await hostRef.get();
          hostData = hostSnap.data() ?? {'isVerified': false};
        } catch (e) {
          print('⚠️ Failed to fetch host data: $e');
        }
      }

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

      // Use GeoPoint if available, otherwise use placeholder (0,0) for manual location
      final GeoPoint locationGeoPoint = _selectedGeoPoint ?? const GeoPoint(0, 0);
      
      // Determine location text: use manual input or selected label
      final locationText = _manualLocation ?? 
                          _locationSearchController.text.trim();
      
      final Map<String, dynamic> experience = {
        'title': title,
        'summary': summary,
        'categories': categories,
        'department': department,
        'duration': duration,
        'hostId': hostDocId, // Store as string for offline compatibility
        'hostDocId': hostDocId,
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
        'location': {
          'latitude': locationGeoPoint.latitude,
          'longitude': locationGeoPoint.longitude,
        }, // Store as map for offline compatibility
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
        'createdAt': DateTime.now().toIso8601String(), // Use ISO string for offline
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add manual location text if no precise GeoPoint
      if (_selectedGeoPoint == null && locationText.isNotEmpty) {
        experience['manualLocationText'] = locationText;
        experience['needsGeocoding'] = true; // Flag for later geocoding
      }

      // Get local image paths that haven't been uploaded yet
      final localImagePaths = _localPhotos
          .map((file) => file.path)
          .toList();

      // Use offline-capable service method
      final experienceId =
          await _experienceService.createExperienceOfflineCapable(
              experience, localImagePaths);

      await _hostPrefs.saveLanguages(_selectedLanguages);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to My Experiences screen
      context.go('/my-experiences');

      // Show appropriate success message
      final message = experienceId != null
          ? 'Experience created successfully!'
          : 'Experience saved offline. Will sync when online.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
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
