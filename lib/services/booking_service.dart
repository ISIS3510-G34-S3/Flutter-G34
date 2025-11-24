import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_connect/models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createBooking({
    required String experienceId,
    required DateTime startsAt,
    required DateTime endsAt,
    required int peopleCount,
    required int amountCOP,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to book an experience');
    }

    // Use email as travelerID if available, otherwise UID
    // This matches the pattern seen in the screenshots provided by the user
    final travelerId = user.email ?? user.uid;

    final bookingData = {
      'experienceId': experienceId,
      'travelerID': '/users/$travelerId', // Reference format as seen in screenshot
      'amountCOP': amountCOP,
      'peopleCount': peopleCount,
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': 'active', // Default status based on screenshot
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('experiences')
        .doc(experienceId)
        .collection('bookings')
        .add(bookingData);
  }

  Stream<List<Booking>> watchBookingsForExperience(String experienceId) {
    return _firestore
        .collection('experiences')
        .doc(experienceId)
        .collection('bookings')
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }
}
