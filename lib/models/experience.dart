import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  final String id;
  final String title;
  final String summary;
  final String hostId;
  final bool hostVerified;
  final GeoPoint location;
  final String department;
  final double avgRating;
  final int reviewsCount;
  final int duration;
  final List<String> skillsToLearn;
  final List<String> skillsToTeach;
  final List<String> categories;
  final List<String> languages;
  final DateTime createdAt;
  final int priceCOP;
  final int groupSizeMax;
  final List<String> paymentOptions;
  final List<String> images;
  final bool isActive;

  const Experience({
    required this.id,
    required this.title,
    required this.summary,
    required this.hostId,
    required this.hostVerified,
    required this.location,
    required this.department,
    required this.avgRating,
    required this.reviewsCount,
    required this.duration,
    required this.skillsToLearn,
    required this.skillsToTeach,
    required this.categories,
    required this.languages,
    required this.createdAt,
    required this.priceCOP,
    required this.groupSizeMax,
    required this.paymentOptions,
    required this.images,
    required this.isActive,
  });

  factory Experience.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Debug: Print the raw data
    print('=== Processing document: ${doc.id} ===');
    print('Raw data: $data');
    print('Data types:');
    data.forEach((key, value) {
      print('  $key: ${value.runtimeType} = $value');
    });

    // Handle hostId which might be a DocumentReference or String
    String hostIdValue = '';
    if (data['hostId'] is DocumentReference) {
      hostIdValue = (data['hostId'] as DocumentReference).id;
    } else if (data['hostId'] is String) {
      hostIdValue = data['hostId'] as String;
    }

    // Helper function to safely parse boolean values
    bool parseBool(dynamic value, bool defaultValue) {
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      if (value is int) return value != 0;
      return defaultValue;
    }

    // Helper function to safely parse list values
    List<String> parseStringList(dynamic value, String fieldName) {
      try {
        if (value == null) return [];
        if (value is List) return List<String>.from(value);
        if (value is String) {
          print('WARNING: Field "$fieldName" is a String, not a List: $value');
          return []; // or return [value] if you want to wrap it
        }
        print(
            'WARNING: Field "$fieldName" has unexpected type ${value.runtimeType}: $value');
        return [];
      } catch (e) {
        print('ERROR parsing list field "$fieldName": $e');
        return [];
      }
    }

    return Experience(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      hostId: hostIdValue,
      hostVerified: parseBool(data['hostVerified'], false),
      location: data['location'] as GeoPoint,
      department: data['department'] ?? '',
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: data['reviewsCount'] ?? 0,
      duration: data['duration'] ?? 0,
      skillsToLearn: parseStringList(data['skillsToLearn'], 'skillsToLearn'),
      skillsToTeach: parseStringList(data['skillsToTeach'], 'skillsToTeach'),
      categories: parseStringList(data['categories'], 'categories'),
      languages: parseStringList(data['languages'], 'languages'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priceCOP: data['priceCOP'] ?? 0,
      groupSizeMax: data['groupSizeMax'] ?? 0,
      paymentOptions: parseStringList(data['paymentOptions'], 'paymentOptions'),
      images: parseStringList(data['images'], 'images'),
      isActive: parseBool(data['isActive'], false),
    );
  }
}
