import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Experiences table - stores cultural experiences
class Experiences extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get hostId => text()();
  BoolColumn get hostVerified => boolean().withDefault(const Constant(false))();
  RealColumn get locationLat => real()();
  RealColumn get locationLng => real()();
  TextColumn get department => text()();
  RealColumn get avgRating => real().withDefault(const Constant(0.0))();
  IntColumn get reviewsCount => integer().withDefault(const Constant(0))();
  IntColumn get duration => integer()();
  TextColumn get skillsToLearn => text()(); // JSON array as string
  TextColumn get skillsToTeach => text()(); // JSON array as string
  TextColumn get categories => text()(); // JSON array as string
  TextColumn get languages => text()(); // JSON array as string
  TextColumn get paymentOptions => text()(); // JSON array as string
  TextColumn get images => text()(); // JSON array as string
  TextColumn get accessibilityFeatures =>
      text().withDefault(const Constant('[]'))(); // JSON array as string
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get priceCOP => integer()();
  IntColumn get groupSizeMax => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // Needs sync to Firebase

  @override
  Set<Column> get primaryKey => {id};
}

/// Users/Hosts table - stores user profiles
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  RealColumn get avgHostRating => real().withDefault(const Constant(0.0))();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  DateTimeColumn get memberSince => dateTime()();
  TextColumn get languages => text()(); // JSON array as string
  TextColumn get responseRate => text().withDefault(const Constant('N/A'))();
  TextColumn get about =>
      text().withDefault(const Constant('Tell others about yourself.'))();
  IntColumn get hostedExperiences => integer().withDefault(const Constant(0))();
  IntColumn get joinedExperiences => integer().withDefault(const Constant(0))();
  TextColumn get photoURL => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get isDirty =>
      boolean().withDefault(const Constant(false))(); // Needs sync to Firebase

  @override
  Set<Column> get primaryKey => {id};
}

/// The Drift database that manages local SQLite storage
@DriftDatabase(tables: [Experiences, Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  // ============================================
  // EXPERIENCE CRUD OPERATIONS
  // ============================================

  /// Get all experiences from local database
  Future<List<Experience>> getAllExperiences() async {
    return await select(experiences).get();
  }

  /// Get a single experience by ID
  Future<Experience?> getExperienceById(String id) async {
    return await (select(experiences)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert or update an experience (upsert)
  Future<void> upsertExperience(ExperiencesCompanion experience) async {
    await into(experiences).insertOnConflictUpdate(experience);
  }

  /// Batch upsert experiences (efficient for syncing multiple records)
  Future<void> upsertExperiences(
      List<ExperiencesCompanion> experienceList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(experiences, experienceList);
    });
  }

  /// Delete an experience by ID
  Future<int> deleteExperience(String id) async {
    return await (delete(experiences)..where((e) => e.id.equals(id))).go();
  }

  /// Get experiences that need to be synced (isDirty = true)
  Future<List<Experience>> getDirtyExperiences() async {
    return await (select(experiences)..where((e) => e.isDirty.equals(true)))
        .get();
  }

  /// Mark an experience as synced (isDirty = false)
  Future<void> markExperienceSynced(String id) async {
    await (update(experiences)..where((e) => e.id.equals(id))).write(
      ExperiencesCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get experiences by host ID
  Future<List<Experience>> getExperiencesByHostId(String hostId) async {
    return await (select(experiences)..where((e) => e.hostId.equals(hostId)))
        .get();
  }

  // ============================================
  // USER CRUD OPERATIONS
  // ============================================

  /// Get all users from local database
  Future<List<User>> getAllUsers() async {
    return await select(users).get();
  }

  /// Get a single user by ID
  Future<User?> getUserById(String id) async {
    return await (select(users)..where((u) => u.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert or update a user (upsert)
  Future<void> upsertUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  /// Batch upsert users (efficient for syncing multiple records)
  Future<void> upsertUsers(List<UsersCompanion> userList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(users, userList);
    });
  }

  /// Delete a user by ID
  Future<int> deleteUser(String id) async {
    return await (delete(users)..where((u) => u.id.equals(id))).go();
  }

  /// Get users that need to be synced (isDirty = true)
  Future<List<User>> getDirtyUsers() async {
    return await (select(users)..where((u) => u.isDirty.equals(true))).get();
  }

  /// Mark a user as synced (isDirty = false)
  Future<void> markUserSynced(String id) async {
    await (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        isDirty: const Value(false),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================
  // UTILITY OPERATIONS
  // ============================================

  /// Clear all experiences from the database
  Future<void> clearAllExperiences() async {
    await delete(experiences).go();
  }

  /// Clear all users from the database
  Future<void> clearAllUsers() async {
    await delete(users).go();
  }

  /// Clear all data from the database (useful for logout or reset)
  Future<void> clearAllData() async {
    await delete(experiences).go();
    await delete(users).go();
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final experienceCount = await (selectOnly(experiences)
          ..addColumns([experiences.id.count()]))
        .getSingle();
    final userCount =
        await (selectOnly(users)..addColumns([users.id.count()])).getSingle();

    return {
      'experiences': experienceCount.read(experiences.id.count()) ?? 0,
      'users': userCount.read(users.id.count()) ?? 0,
    };
  }
}

/// Opens a connection to the SQLite database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'travel_connect.sqlite'));
    return NativeDatabase(file);
  });
}
