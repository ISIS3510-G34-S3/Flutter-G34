import 'package:cloud_firestore/cloud_firestore.dart';

class Host {
  final String id;
  final String name;
  final String email;
  final double avgHostRating;
  final bool isVerified;
  final DateTime memberSince;
  final List<String> languages;
  final String responseRate;
  final String about;
  final int hostedExperiences;
  final int joinedExperiences;
  final String? photoURL;

  const Host({
    required this.id,
    required this.name,
    required this.email,
    required this.avgHostRating,
    required this.isVerified,
    required this.memberSince,
    required this.languages,
    required this.responseRate,
    required this.about,
    required this.hostedExperiences,
    required this.joinedExperiences,
    this.photoURL,
  });

  factory Host.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper for safe boolean parsing
    bool _parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    // Helper for safe list parsing
    List<String> _parseStringList(dynamic value) {
      if (value is List) {
        return List<String>.from(value.map((item) => item.toString()));
      }
      return [];
    }

    return Host(
      id: doc.id,
      name: data['displayName'] ?? data['name'] ?? 'User',
      email: data['email'] ?? '',
      avgHostRating: (data['avgHostRating'] as num?)?.toDouble() ?? 0.0,
      isVerified: _parseBool(data['isVerified']),
      memberSince: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      languages: _parseStringList(data['languages']),
      responseRate: data['responseRate'] ?? 'N/A',
      about: data['about'] ?? 'Tell others about yourself.',
      hostedExperiences: data['hostedExperiences'] ?? 0,
      joinedExperiences: data['joinedExperiences'] ?? 0,
      photoURL: data['photoURL'] as String?,
    );
  }
}