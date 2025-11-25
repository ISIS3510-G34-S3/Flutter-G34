import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_connect/models/booking.dart';
import 'pending_operations_service.dart';

class BookingService {
  BookingService._internal();
  static final BookingService _instance = BookingService._internal();

  factory BookingService() {
    _instance.startConnectivityMonitoring();
    return _instance;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PendingOperationsService _pendingOps = PendingOperationsService();
  final Connectivity connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  Future<void> createBooking(Booking booking) async {
    try {
      final bookingData = booking.toMap();
      bookingData['createdAt'] = FieldValue.serverTimestamp();
      
      // Ensure travelerID is populated
      if (bookingData['travelerID'] == null ||
          bookingData['travelerID'].toString().isEmpty) {
        final user = _auth.currentUser;
        if (user != null) {
          bookingData['travelerID'] = (user.email ?? user.uid).toLowerCase();
        }
      }

      // Ensure travelerID is a DocumentReference
      if (bookingData['travelerID'] is String) {
        String path = bookingData['travelerID'];
        // Remove leading slash if present
        if (path.startsWith('/')) path = path.substring(1);
        // Add collection prefix if missing
        if (!path.startsWith('users/')) path = 'users/$path';
        bookingData['travelerID'] = _firestore.doc(path);
      }

      await _firestore
          .collection('experiences')
          .doc(booking.experienceId)
          .collection('bookings')
          .add(bookingData);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  /// Create a booking with offline support
  /// Returns true if created online, false if queued offline
  Future<bool> createBookingOfflineCapable(Booking booking) async {
    final isOnline = await hasConnectivity();

    if (isOnline) {
      try {
        await createBooking(booking);
        print('✓ Booking created online');
        return true;
      } catch (e) {
        print('❌ Failed to create booking online: $e');
        // Fall through to offline queue
      }
    }

    // Queue for later sync
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    final bookingData = booking.toMap();
    
    // Ensure travelerID is populated before queuing
    if (bookingData['travelerID'] == null ||
        bookingData['travelerID'].toString().isEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        bookingData['travelerID'] = (user.email ?? user.uid).toLowerCase();
      }
    }

    // Store travelerID as string for JSON serialization
    if (bookingData['travelerID'] is DocumentReference) {
      bookingData['travelerID'] =
          (bookingData['travelerID'] as DocumentReference).path;
    } else if (bookingData['travelerID'] is String) {
      // Ensure it's a full path
      String path = bookingData['travelerID'];
      if (path.startsWith('/')) path = path.substring(1);
      if (!path.startsWith('users/')) path = 'users/$path';
      bookingData['travelerID'] = path;
    }
    
    // Convert Timestamps to Strings for JSON serialization
    if (bookingData['startsAt'] is Timestamp) {
      bookingData['startsAt'] = (bookingData['startsAt'] as Timestamp).toDate().toIso8601String();
    }
    if (bookingData['endsAt'] is Timestamp) {
      bookingData['endsAt'] = (bookingData['endsAt'] as Timestamp).toDate().toIso8601String();
    }
    if (bookingData['createdAt'] is Timestamp) {
      bookingData['createdAt'] = (bookingData['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    await _pendingOps.addPendingOperation(
      PendingOperation(
        id: operationId,
        type: 'create_booking',
        data: bookingData,
        experienceId: booking.experienceId,
        timestamp: DateTime.now(),
      ),
    );
    print('📥 Booking queued for later sync (offline)');
    return false;
  }

  Stream<List<Booking>> watchBookingsForExperience(String experienceId) {
    return _firestore
        .collection('experiences')
        .doc(experienceId)
        .collection('bookings')
        .orderBy('startsAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Stream<List<Booking>> getBookingsByTraveler() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    final travelerId = (user.email ?? user.uid).toLowerCase();
    final travelerRef = _firestore.doc('users/$travelerId');

    // STEP 1: Try to get data from cache first
    try {
      final cacheSnapshot = await _firestore
          .collectionGroup('bookings')
          .where('travelerID', isEqualTo: travelerRef)
          .orderBy('startsAt', descending: true)
          .get(const GetOptions(source: Source.cache));

      if (cacheSnapshot.docs.isNotEmpty) {
        final bookings = cacheSnapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList();
        print('✓ Loaded ${bookings.length} bookings from cache');
        yield bookings;
      }
    } catch (e) {
      print('Cache miss or error fetching bookings: $e');
    }

    // STEP 2: Subscribe to real-time updates (Network)
    yield* _firestore
        .collectionGroup('bookings')
        .where('travelerID', isEqualTo: travelerRef)
        .orderBy('startsAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
      print('✓ Loaded ${bookings.length} bookings from network');
      return bookings;
    });
  }

  Future<void> deleteBooking(String experienceId, String bookingId) async {
    try {
      await _firestore
          .collection('experiences')
          .doc(experienceId)
          .collection('bookings')
          .doc(bookingId)
          .delete();
    } catch (e) {
      print('Error deleting booking: $e');
      rethrow;
    }
  }

  // Connectivity and Sync Logic

  Future<bool> hasConnectivity() async {
    final results = await connectivity.checkConnectivity();
    return results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  void startConnectivityMonitoring() {
    if (_connectivitySubscription != null) return;

    _checkAndSyncOnStartup();

    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isConnected = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);

        if (isConnected) {
          if (!_isSyncing) {
            print('🌐 Connectivity restored (BookingService), checking pending bookings...');
            syncPendingBookings();
          }
        }
      },
    );
  }

  Future<void> _checkAndSyncOnStartup() async {
    final isOnline = await hasConnectivity();
    if (isOnline && !_isSyncing) {
      print('📱 App started online (BookingService), checking pending bookings...');
      await syncPendingBookings();
    }
  }

  Future<void> syncPendingBookings() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _pendingOps.getPendingOperations();
      final pendingBookings = pending.where((op) => op.type == 'create_booking').toList();

      if (pendingBookings.isEmpty) {
        _isSyncing = false;
        return;
      }

      print('🔄 Syncing ${pendingBookings.length} pending bookings...');

      for (final operation in pendingBookings) {
        try {
          final bookingData = Map<String, dynamic>.from(operation.data);
          
          // Restore travelerID to DocumentReference if needed
          // Note: createBooking handles string paths too, but let's be safe
          if (bookingData['travelerID'] is String) {
             // It's already a path string like /users/email, createBooking handles conversion
          }

          // Use the raw create logic, but we need to reconstruct a Booking object?
          // Or just insert directly. Inserting directly is easier since we have the map.
          
          // Convert ISO strings back to Timestamps for Firestore
          if (bookingData['startsAt'] is String) {
             bookingData['startsAt'] = Timestamp.fromDate(DateTime.parse(bookingData['startsAt']));
          }
          if (bookingData['endsAt'] is String) {
             bookingData['endsAt'] = Timestamp.fromDate(DateTime.parse(bookingData['endsAt']));
          }

          bookingData['createdAt'] = FieldValue.serverTimestamp();
           if (bookingData['travelerID'] is String) {
            bookingData['travelerID'] = _firestore.doc(bookingData['travelerID']);
          }

          if (operation.experienceId != null) {
             await _firestore
                .collection('experiences')
                .doc(operation.experienceId)
                .collection('bookings')
                .add(bookingData);
             
             print('✓ Synced pending booking: ${operation.id}');
             await _pendingOps.removePendingOperation(operation.id);
          }
        } catch (e) {
          print('❌ Failed to sync booking ${operation.id}: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
