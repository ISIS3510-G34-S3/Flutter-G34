import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = !result.contains(ConnectivityResult.none);
      debugPrint('📡 Connectivity check: ${_isOnline ? "Online" : "Offline"}');
      return _isOnline;
    } catch (e) {
      debugPrint('⚠️ Error checking connectivity: $e');
      // Assume online if check fails (optimistic approach)
      _isOnline = true;
      return true;
    }
  }

  /// Start listening to connectivity changes
  void startMonitoring(Function(bool isOnline) onConnectivityChanged) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = !results.contains(ConnectivityResult.none);

        if (wasOnline != _isOnline) {
          debugPrint(
              '📡 Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
          onConnectivityChanged(_isOnline);
        }
      },
    );
  }

  /// Stop listening to connectivity changes
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
