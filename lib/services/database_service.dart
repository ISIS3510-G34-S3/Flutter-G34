import 'package:travel_connect/database/app_database.dart';

/// Singleton service to manage the database instance
/// 
/// This ensures only one database connection is active throughout the app lifecycle
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static AppDatabase? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// Get the database instance (creates if not exists)
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// Close the database connection (call on app termination)
  Future<void> close() async {
    if (_database != null) {
      // Drift databases don't need explicit closing in most cases
      // but we can null it out for cleanup
      _database = null;
    }
  }
}
