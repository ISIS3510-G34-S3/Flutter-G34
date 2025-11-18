import 'dart:io';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Wraps screens with connectivity awareness and offline protection
///
/// Features:
/// - Persistent offline banner when no connection
/// - Automatic connectivity monitoring
/// - Optional blocking of UI interactions when offline
/// - Customizable offline messaging
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final bool requiresConnection;
  final String? offlineMessage;
  final VoidCallback? onConnectivityChanged;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.requiresConnection = false,
    this.offlineMessage,
    this.onConnectivityChanged,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    _isOnline = await _connectivityService.checkConnectivity();

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }

    // Start monitoring connectivity changes
    _connectivityService.startMonitoring((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
        widget.onConnectivityChanged?.call();
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking initial connectivity
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        // Offline banner
        if (!_isOnline) _buildOfflineBanner(),

        // Main content
        Expanded(
          child: widget.requiresConnection && !_isOnline
              ? _buildOfflineBlocker()
              : widget.child,
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.oliveGold.withValues(alpha: 0.2),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              Icons.cloud_off,
              size: 16,
              color: AppColors.oliveGold,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No internet connection - using offline data',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.oliveGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBlocker() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Soft circular icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.oliveGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_outlined,
                  size: 40,
                  color: AppColors.oliveGold,
                ),
              ),
              const SizedBox(height: 24),
              // Friendly title
              Text(
                'Connection needed',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Helpful message
              Text(
                widget.offlineMessage ??
                    'Connect to the internet to use this feature',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Subtle retry button
              OutlinedButton.icon(
                onPressed: () async {
                  setState(() {
                    _isChecking = true;
                  });
                  await _connectivityService.checkConnectivity();
                  if (mounted) {
                    setState(() {
                      _isOnline = _connectivityService.isOnline;
                      _isChecking = false;
                    });
                  }
                },
                icon: Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.oliveGold,
                  side: BorderSide(
                      color: AppColors.oliveGold.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper mixin for screens that need connectivity awareness
mixin ConnectivityAware<T extends StatefulWidget> on State<T> {
  final ConnectivityService connectivityService = ConnectivityService();
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    isOnline = await connectivityService.checkConnectivity();
    if (mounted) setState(() {});

    connectivityService.startMonitoring((online) {
      if (mounted) {
        setState(() {
          isOnline = online;
        });
        onConnectivityChanged(online);
      }
    });
  }

  @override
  void dispose() {
    connectivityService.stopMonitoring();
    super.dispose();
  }

  /// Override this to handle connectivity changes
  void onConnectivityChanged(bool isOnline) {}

  /// Show offline snackbar with friendly styling
  void showOfflineSnackbar([String? message]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cloud_off, color: AppColors.oliveGold, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message ?? 'This action requires an internet connection',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.oliveGold.withValues(alpha: 0.2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.oliveGold.withValues(alpha: 0.4)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Execute operation only if online, otherwise show error
  Future<T?> executeIfOnline<T>({
    required Future<T> Function() operation,
    String? offlineMessage,
  }) async {
    if (!isOnline) {
      showOfflineSnackbar(offlineMessage);
      return null;
    }

    try {
      return await operation();
    } on SocketException {
      showOfflineSnackbar('Network error. Please check your connection.');
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Build a subtle offline banner widget (matches Discover screen style)
  Widget buildOfflineBanner() {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.oliveGold.withValues(alpha: 0.2),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: AppColors.oliveGold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No internet connection - using offline data',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.oliveGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
