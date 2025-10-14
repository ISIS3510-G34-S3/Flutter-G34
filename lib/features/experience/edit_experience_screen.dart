import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../mock/mock_data.dart' as mock;
import 'package:travel_connect/models/experience.dart';
import 'package:travel_connect/services/experience_service.dart';
import 'package:travel_connect/theme/colors.dart';
import 'package:travel_connect/theme/typography.dart';

class EditExperienceScreen extends StatefulWidget {
  const EditExperienceScreen({super.key, required this.experienceId});

  final String experienceId;

  @override
  State<EditExperienceScreen> createState() => _EditExperienceScreenState();
}

class _EditExperienceScreenState extends State<EditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExperienceService _service = ExperienceService();

  Experience? _experience;
  bool _isLoading = true;

  // Controllers mirroring create screen
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _groupSizeController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedLanguages = [];
  List<String> _selectedPaymentOptions = [];
  final List<String> _imageUrls = [];

  GeoPoint? _geoPoint;
  String? _department;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final exp = await _service.getExperienceById(widget.experienceId);
    if (!mounted) return;
    setState(() {
      _experience = exp;
      _isLoading = false;
    });
    if (exp != null) {
      _titleController.text = exp.title;
      _descriptionController.text = exp.summary;
      _durationController.text = exp.duration.toString();
      _priceController.text = exp.priceCOP.toString();
      _groupSizeController.text = exp.groupSizeMax.toString();
      _selectedCategories = List<String>.from(exp.categories);
      _selectedLanguages = List<String>.from(exp.languages);
      _selectedPaymentOptions = List<String>.from(exp.paymentOptions);
      _imageUrls.addAll(exp.images);
      _geoPoint = exp.location;
      _department = exp.department;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _groupSizeController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? captured = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear, imageQuality: 85);
    if (captured == null) return;

    final String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File file = File(captured.path);

    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://travelappbd-8e204.firebasestorage.app',
    );
    final ref = storage.ref().child('experiences/${_experience?.hostId}/$fileName');
    final uploadTask = await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final String downloadUrl = await uploadTask.ref.getDownloadURL();

    if (!mounted) return;
    setState(() {
      _imageUrls.add(downloadUrl);
    });

    await _service.updateExperience(widget.experienceId, {
      'images': _imageUrls,
    });
  }

  Future<void> _removePhoto(String url) async {
    if (_imageUrls.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Experiences must have at least 1 photo',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.lava,
        ),
      );
      return;
    }
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://travelappbd-8e204.firebasestorage.app',
      );
      await storage.refFromURL(url).delete();
    } catch (_) {
      // ignore storage delete error
    }
    if (!mounted) return;
    setState(() {
      _imageUrls.remove(url);
    });
    await _service.updateExperience(widget.experienceId, {
      'images': _imageUrls,
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> updates = {
      'title': _titleController.text.trim(),
      'summary': _descriptionController.text.trim(),
      'duration': int.tryParse(_durationController.text.trim()) ?? 0,
      'priceCOP': int.tryParse(_priceController.text.trim()) ?? 0,
      'groupSizeMax': int.tryParse(_groupSizeController.text.trim()) ?? 0,
      'categories': _selectedCategories,
      'languages': _selectedLanguages,
      'paymentOptions': _selectedPaymentOptions,
      'images': _imageUrls,
      'department': _department ?? '',
      'location': _geoPoint,
    };
    await _service.updateExperience(widget.experienceId, updates);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Experience updated',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.forestGreen,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Experience',
          style: AppTypography.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save', style: AppTypography.buttonMedium.copyWith(color: AppColors.white)),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Photos', style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index < _imageUrls.length) {
                          final url = _imageUrls[index];
                          return Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(url, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: InkWell(
                                  onTap: () => _removePhoto(url),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                        return _buildAddPhotoButton();
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemCount: (_imageUrls.length + 1).clamp(1, 8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField('Experience Title', _titleController, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 20),
                  _buildTextField('Description', _descriptionController, maxLines: 4, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 20),
                  _buildCategoryMultiSelect(),
                  const SizedBox(height: 20),
                  _buildTextField('Duration (hours)', _durationController, keyboardType: TextInputType.number, validator: _validateNonNegativeInt),
                  const SizedBox(height: 20),
                  _buildTextField('Price (COP)', _priceController, keyboardType: TextInputType.number, validator: _validateNonNegativeInt),
                  const SizedBox(height: 20),
                  _buildTextField('Max Group Size', _groupSizeController, keyboardType: TextInputType.number, validator: _validateNonNegativeInt),
                  const SizedBox(height: 20),
                  _buildChipsSection(
                    label: 'Languages',
                    options: const ['es', 'en', 'pt', 'fr'],
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
                  _buildChipsSection(
                    label: 'Payment Options',
                    options: const ['cash', 'card'],
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
                ],
              ),
            ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.divider, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text('Add Photo', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String? _validateNonNegativeInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final ok = RegExp(r'^\d+$').hasMatch(value.trim());
    if (!ok) return 'Invalid number';
    return null;
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

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
          children: mock.MockData.categories.map((category) {
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
}


