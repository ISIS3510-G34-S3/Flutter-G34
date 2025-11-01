import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

class HostPreferencesService {
  HostPreferencesService._internal();
  static final HostPreferencesService _instance = HostPreferencesService._internal();

  factory HostPreferencesService() => _instance;

  static const String _languagesKey = 'preferred_languages';

  Future<void> saveLanguages(List<String> languages) async {
    final prefs = await SharedPreferences.getInstance();
    final filtered = languages
        .map((lang) => lang.trim())
        .where((lang) => lang.isNotEmpty)
        .toList();
    if (filtered.isEmpty) {
      await prefs.remove(_languagesKey);
      return;
    }

    final unique = LinkedHashSet<String>.from(filtered);
    await prefs.setStringList(_languagesKey, unique.toList());
  }

  Future<List<String>> loadLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_languagesKey);
    if (stored == null || stored.isEmpty) return const [];

    final unique = LinkedHashSet<String>.from(
        stored.map((lang) => lang.trim()).where((lang) => lang.isNotEmpty));
    return List<String>.from(unique);
  }
}

