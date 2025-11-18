import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Enterprise-grade connectivity service with HTTP reachability testing
/// Works correctly even in airplane mode with WiFi enabled
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicCheckTimer;

  bool _isOnline = true; // Optimistic default for better UX
  DateTime? _lastSuccessfulCheck;

  // Configuration constants
  static const Duration _checkTimeout = Duration(seconds: 5);
  static const Duration _periodicCheckInterval = Duration(seconds: 30);
  static const int _maxRetries = 2;
  static const List<String> _testUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://www.amazon.com',
  ];

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Last successful connectivity check timestamp
  DateTime? get lastSuccessfulCheck => _lastSuccessfulCheck;

  /// Comprehensive connectivity check using HTTP reachability test
  /// This works in airplane mode with WiFi, unlike connectivity_plus alone
  Future<bool> checkConnectivity() async {
    debugPrint(
        '🔍 [ConnectivityService] Starting comprehensive connectivity check...');

    // Step 1: Check device connectivity state (WiFi/Mobile/None)
    try {
      final result = await _connectivity.checkConnectivity();
      final hasDeviceConnection = !result.contains(ConnectivityResult.none);

      if (!hasDeviceConnection) {
        debugPrint(
            '📡 [ConnectivityService] Device reports no connection (airplane mode or disabled)');
        _isOnline = false;
        return false;
      }

      debugPrint(
          '📡 [ConnectivityService] Device has connectivity interface: ${result.toString()}');
    } catch (e) {
      debugPrint(
          '⚠️ [ConnectivityService] Error checking device connectivity: $e');
      // Continue to HTTP test even if this fails
    }

    // Step 2: Perform actual HTTP reachability test with retry logic
    _isOnline = await _performHttpReachabilityTest();

    if (_isOnline) {
      _lastSuccessfulCheck = DateTime.now();
      debugPrint('✅ [ConnectivityService] ONLINE - Internet is reachable');
    } else {
      debugPrint('❌ [ConnectivityService] OFFLINE - No internet connectivity');
    }

    return _isOnline;
  }

  /// Perform HTTP reachability test with exponential backoff retry
  Future<bool> _performHttpReachabilityTest() async {
    // Quick first attempt - try just one fast URL
    try {
      final quickCheck = await _testSingleUrl(_testUrls[0]);
      if (quickCheck) {
        debugPrint('✅ [ConnectivityService] Quick check succeeded');
        return true;
      }
    } catch (e) {
      debugPrint(
          '⚠️ [ConnectivityService] Quick check failed, trying all URLs...');
    }

    // If quick check failed, try all URLs with retry
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      if (attempt > 0) {
        // Exponential backoff: 1s, 2s
        final delaySeconds = 1 << (attempt - 1);
        debugPrint(
            '⏳ [ConnectivityService] Retry attempt $attempt after ${delaySeconds}s delay...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }

      // Try multiple URLs in parallel for faster detection
      try {
        final results = await Future.wait(
          _testUrls.map((url) => _testSingleUrl(url)),
          eagerError: false,
        );

        // If any URL succeeded, we're online
        if (results.any((success) => success)) {
          debugPrint('✅ [ConnectivityService] HTTP reachability confirmed');
          return true;
        }
      } catch (e) {
        debugPrint(
            '⚠️ [ConnectivityService] HTTP test error (attempt ${attempt + 1}/$_maxRetries): $e');
      }
    }

    return false;
  }

  /// Test a single URL for reachability
  Future<bool> _testSingleUrl(String url) async {
    try {
      final response = await http
          .head(
        Uri.parse(url),
      )
          .timeout(
        _checkTimeout,
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      final isSuccess = response.statusCode >= 200 && response.statusCode < 500;
      if (isSuccess) {
        debugPrint(
            '✅ [ConnectivityService] Reachable: $url (${response.statusCode})');
      }
      return isSuccess;
    } on SocketException catch (e) {
      debugPrint('❌ [ConnectivityService] Socket error for $url: ${e.message}');
      return false;
    } on TimeoutException {
      debugPrint('⏱️ [ConnectivityService] Timeout for $url');
      return false;
    } on HttpException catch (e) {
      debugPrint('❌ [ConnectivityService] HTTP error for $url: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ [ConnectivityService] Error testing $url: $e');
      return false;
    }
  }

  /// Start monitoring connectivity changes with periodic verification
  void startMonitoring(Function(bool isOnline) onConnectivityChanged) {
    stopMonitoring(); // Clean up any existing monitoring

    // Initial check
    checkConnectivity().then((isOnline) {
      onConnectivityChanged(isOnline);
    });

    // Listen to device connectivity changes (WiFi/Mobile/None)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final hasConnection = !results.contains(ConnectivityResult.none);
        debugPrint(
            '📡 [ConnectivityService] Device connectivity changed: $results');

        if (!hasConnection) {
          // Device lost all connections
          if (_isOnline) {
            _isOnline = false;
            debugPrint(
                '❌ [ConnectivityService] Lost all connections - going OFFLINE');
            onConnectivityChanged(false);
          }
        } else {
          // Device gained connection - verify with HTTP test
          debugPrint(
              '🔄 [ConnectivityService] Device gained connection - verifying...');
          final wasOnline = _isOnline;
          await checkConnectivity();

          if (wasOnline != _isOnline) {
            debugPrint(
                '📡 [ConnectivityService] Status changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
            onConnectivityChanged(_isOnline);
          }
        }
      },
    );

    // Periodic HTTP reachability checks (handles edge cases)
    _periodicCheckTimer = Timer.periodic(_periodicCheckInterval, (timer) async {
      debugPrint('⏰ [ConnectivityService] Periodic connectivity check...');
      final wasOnline = _isOnline;
      await checkConnectivity();

      if (wasOnline != _isOnline) {
        debugPrint(
            '📡 [ConnectivityService] Periodic check detected change: ${_isOnline ? "ONLINE" : "OFFLINE"}');
        onConnectivityChanged(_isOnline);
      }
    });
  }

  /// Stop listening to connectivity changes
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
    debugPrint('🛑 [ConnectivityService] Monitoring stopped');
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }

  /// Execute an online-only operation with automatic retry and connectivity check
  Future<T> executeOnlineOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxRetries = 2,
  }) async {
    // Verify we're online first
    if (!_isOnline) {
      final isOnlineNow = await checkConnectivity();
      if (!isOnlineNow) {
        throw ConnectivityException(
            'No internet connection available for: $operationName');
      }
    }

    Exception? lastException;

    for (int attempt = 0; attempt < maxRetries + 1; attempt++) {
      try {
        debugPrint(
            '🚀 [ConnectivityService] Executing: $operationName (attempt ${attempt + 1})');
        final result = await operation();
        debugPrint('✅ [ConnectivityService] Success: $operationName');
        return result;
      } on SocketException catch (e) {
        lastException = e;
        debugPrint(
            '❌ [ConnectivityService] Network error in $operationName: ${e.message}');

        // Check if we lost connectivity
        await checkConnectivity();
        if (!_isOnline || attempt >= maxRetries) {
          break;
        }

        // Exponential backoff
        await Future.delayed(Duration(seconds: 1 << attempt));
      } on TimeoutException catch (e) {
        lastException = e;
        debugPrint('⏱️ [ConnectivityService] Timeout in $operationName');

        if (attempt >= maxRetries) {
          break;
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        debugPrint('❌ [ConnectivityService] Error in $operationName: $e');
        rethrow;
      }
    }

    throw lastException ??
        ConnectivityException('Operation failed: $operationName');
  }
}

/// Custom exception for connectivity-related errors
class ConnectivityException implements Exception {
  final String message;
  ConnectivityException(this.message);

  @override
  String toString() => 'ConnectivityException: $message';
}
