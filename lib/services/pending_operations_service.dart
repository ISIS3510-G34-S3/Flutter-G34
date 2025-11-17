import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to queue and manage pending Firebase operations when offline
class PendingOperationsService {
  static const String _pendingKey = 'pending_operations';

  /// Add a pending operation to the queue
  Future<void> addPendingOperation(PendingOperation operation) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pending = prefs.getStringList(_pendingKey) ?? [];
    pending.add(jsonEncode(operation.toJson()));
    await prefs.setStringList(_pendingKey, pending);
    print('✓ Queued pending operation: ${operation.type}');
  }

  /// Get all pending operations
  Future<List<PendingOperation>> getPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pending = prefs.getStringList(_pendingKey) ?? [];
    return pending
        .map((json) => PendingOperation.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Remove a pending operation after successful sync
  Future<void> removePendingOperation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pending = prefs.getStringList(_pendingKey) ?? [];
    pending.removeWhere((json) {
      final op = PendingOperation.fromJson(jsonDecode(json));
      return op.id == id;
    });
    await prefs.setStringList(_pendingKey, pending);
    print('✓ Removed pending operation: $id');
  }

  /// Clear all pending operations
  Future<void> clearPendingOperations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }
}

/// Represents a pending Firebase operation
class PendingOperation {
  final String id;
  final String type; // 'create' or 'update'
  final Map<String, dynamic> data;
  final String? experienceId; // null for create, set for update
  final DateTime timestamp;
  final List<String> localImagePaths; // Local file paths for images to upload

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    this.experienceId,
    required this.timestamp,
    this.localImagePaths = const [],
  });

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      experienceId: json['experienceId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      localImagePaths: json['localImagePaths'] != null
          ? List<String>.from(json['localImagePaths'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'experienceId': experienceId,
      'timestamp': timestamp.toIso8601String(),
      'localImagePaths': localImagePaths,
    };
  }
}

