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

    return Experience(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      hostId: data['hostId'] ?? '',
      hostVerified: data['hostVerified'] ?? false,
      location: data['location'] as GeoPoint,
      department: data['department'] ?? '',
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: data['reviewsCount'] ?? 0,
      duration: data['duration'] ?? 0,
      skillsToLearn: List<String>.from(data['skillsToLearn'] ?? []),
      skillsToTeach: List<String>.from(data['skillsToTeach'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priceCOP: data['priceCOP'] ?? 0,
      groupSizeMax: data['groupSizeMax'] ?? 0,
      paymentOptions: List<String>.from(data['paymentOptions'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      isActive: data['isActive'] ?? false,
    );
  }
}
