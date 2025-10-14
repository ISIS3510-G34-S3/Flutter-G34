import 'package:flutter/material.dart';
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
  final _departmentController = TextEditingController();
  final _priceController = TextEditingController();
  final _groupSizeController = TextEditingController();
  final _locationSearchController = TextEditingController();
  final _skillsToTeachController = TextEditingController();
  final _skillsToLearnController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedLanguages = [];
  List<String> _selectedPaymentOptions = [];
  final List<String> _imageUrls = [];
  final List<File> _localPhotos = [];
  GeoPoint? _selectedGeoPoint;
  String? _selectedLocationLabel;
  bool _isLoading = false;

  static const List<String> _languageOptions = ['es', 'en', 'pt', 'fr'];
  static const List<String> _paymentOptions = ['cash', 'card'];
  static const String _placesApiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY', defaultValue: 'AIzaSyA0TPkWq9uNvEA0Qhw2NVBihLbRTroYabE');

  // Google Places typeahead state
  List<Map<String, dynamic>> _placeSuggestions = [];
  bool _isFetchingPlaces = false;
  Timer? _placesDebounce;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _departmentController.dispose();
    _priceController.dispose();
    _groupSizeController.dispose();
    _locationSearchController.dispose();
    _skillsToTeachController.dispose();
    _skillsToLearnController.dispose();
    _placesDebounce?.cancel();
    super.dispose();
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

            // Duration field (hours or days number)
            _buildTextField(
              label: 'Duration',
              controller: _durationController,
              hint: '3 (hours/days)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Department
            _buildTextField(
              label: 'Department',
              controller: _departmentController,
              hint: 'e.g. Tolima',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a department';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Price COP
            _buildTextField(
              label: 'Price (COP)',
              controller: _priceController,
              hint: 'e.g. 120000',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Group size
            _buildTextField(
              label: 'Max Group Size',
              controller: _groupSizeController,
              hint: 'e.g. 8',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter max group size';
                }
                return null;
              },
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

            // Image URLs
            _buildImagesInput(),

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, fit: BoxFit.cover),
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

  Widget _buildImagesInput() {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image URLs',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'https://...'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    _imageUrls.add(url);
                  });
                  controller.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _imageUrls
              .map((u) => Chip(
                    label: Text(u, overflow: TextOverflow.ellipsis),
                    onDeleted: () {
                      setState(() {
                        _imageUrls.remove(u);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

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
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () async {
                    final placeId = s['place_id'] as String?;
                    if (placeId != null) {
                      final details = await _fetchPlaceDetails(placeId);
                      if (!mounted) return;
                      setState(() {
                        _selectedGeoPoint = GeoPoint(details['lat']!, details['lng']!);
                        _selectedLocationLabel = s['description'] as String?;
                        _locationSearchController.text = _selectedLocationLabel ?? '';
                        _placeSuggestions = [];
                      });
                    }
                  },
                );
              },
            ),
          ),
        if (_selectedLocationLabel != null)
          Text(
            'Selected: $_selectedLocationLabel',
            style: AppTypography.bodySmall,
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
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () async {
                    final placeId = s['place_id'] as String?;
                    if (placeId != null) {
                      final details = await _fetchPlaceDetails(placeId);
                      if (!mounted) return;
                      setState(() {
                        _selectedGeoPoint = GeoPoint(details['lat']!, details['lng']!);
                        _selectedLocationLabel = s['description'] as String?;
                        _locationSearchController.text = _selectedLocationLabel ?? '';
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

  Future<List<Map<String, dynamic>>> _fetchPlaceSuggestions(String input) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeQueryComponent(input)}&types=geocode&key=$_placesApiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body) as Map<String, dynamic>;
    final preds = (data['predictions'] as List? ?? []).cast<Map>();
    return preds.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, double>> _fetchPlaceDetails(String placeId) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$_placesApiKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) return {'lat': 0.0, 'lng': 0.0};
    final data = json.decode(res.body) as Map<String, dynamic>;
    final loc = (((data['result'] as Map?)?['geometry'] as Map?)?['location'] as Map?) ?? {};
    return {
      'lat': (loc['lat'] as num?)?.toDouble() ?? 0.0,
      'lng': (loc['lng'] as num?)?.toDouble() ?? 0.0,
    };
  }

  void _addPhoto() {
    _pickAndUploadFromCamera();
  }

  Future<void> _pickAndUploadFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? captured = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear, imageQuality: 85);
      if (captured == null) return;

      // Upload to Firebase Storage under user ID folder
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      final String uid = user.uid;
      final String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File file = File(captured.path);

      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://travelappbd-8e204.firebasestorage.app',
      );
      final ref = storage.ref().child('experiences/$uid/$fileName');
      final uploadTask = await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _localPhotos.add(file);
        _imageUrls.add(downloadUrl);
      });
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
      if (_selectedPaymentOptions.isEmpty) {
        _selectedPaymentOptions = ['cash'];
      }
      if (_selectedLanguages.isEmpty) {
        _selectedLanguages = ['es'];
      }
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        throw Exception('No authenticated user');
      }

      final hostDocId = (authUser.email ?? '').toLowerCase().isNotEmpty
          ? (authUser.email ?? '').toLowerCase()
          : authUser.uid;
      final hostRef = FirebaseFirestore.instance.collection('users').doc(hostDocId);
      final hostSnap = await hostRef.get();
      final hostData = hostSnap.data() ?? <String, dynamic>{};

      final String title = _titleController.text.trim();
      final String summary = _descriptionController.text.trim();
      final String department = _departmentController.text.trim();
      final int duration = int.tryParse(RegExp(r"\d+").stringMatch(_durationController.text) ?? '') ?? 1;
      final List<String> categories = _selectedCategories.map((c) => c.toLowerCase()).toList();
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
      final int groupSizeMax = int.tryParse(_groupSizeController.text.trim()) ?? 8;

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
        'location': _selectedGeoPoint,
        'skillsToTeach': skillsToTeach.isEmpty ? <String>[_skillsToTeachController.text.trim()].where((e) => e.isNotEmpty).toList() : skillsToTeach,
        'skillsToLearn': skillsToLearn.isEmpty ? <String>[_skillsToLearnController.text.trim()].where((e) => e.isNotEmpty).toList() : skillsToLearn,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('experiences').add(experience);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

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

      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _durationController.clear();
      _departmentController.clear();
      _priceController.clear();
      _groupSizeController.clear();
      _locationSearchController.clear();
      _skillsToTeachController.clear();
      _skillsToLearnController.clear();
      setState(() {
        _selectedCategories = [];
        _selectedLanguages = [];
        _selectedPaymentOptions = [];
        _imageUrls.clear();
        _selectedGeoPoint = null;
        _selectedLocationLabel = null;
      });
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
