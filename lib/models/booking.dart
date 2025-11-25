import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String experienceId;
  final String travelerId;
  final int amountCOP;
  final int peopleCount;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.experienceId,
    required this.travelerId,
    required this.amountCOP,
    required this.peopleCount,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      experienceId: data['experienceId'] ?? '',
      travelerId: data['travelerID'] is DocumentReference
          ? (data['travelerID'] as DocumentReference).path
          : data['travelerID'] ?? '', // Note: Firestore field is travelerID
      amountCOP: data['amountCOP'] ?? 0,
      peopleCount: data['peopleCount'] ?? 1,
      startsAt: (data['startsAt'] as Timestamp).toDate(),
      endsAt: (data['endsAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'experienceId': experienceId,
      'travelerID': travelerId,
      'amountCOP': amountCOP,
      'peopleCount': peopleCount,
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
