import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:travel_connect/models/experience.dart' as models;
import 'package:travel_connect/models/host.dart' as models;
import 'app_database.dart';

/// Converter utilities for transforming between Firestore, Drift, and Domain models
class DatabaseConverters {
  /// Convert Firestore Experience to Drift ExperiencesCompanion
  static ExperiencesCompanion experienceToCompanion(
    models.Experience experience, {
    bool markDirty = false,
  }) {
    return ExperiencesCompanion(
      id: drift.Value(experience.id),
      title: drift.Value(experience.title),
      summary: drift.Value(experience.summary),
      hostId: drift.Value(experience.hostId),
      hostVerified: drift.Value(experience.hostVerified),
      locationLat: drift.Value(experience.location.latitude),
      locationLng: drift.Value(experience.location.longitude),
      department: drift.Value(experience.department),
      avgRating: drift.Value(experience.avgRating),
      reviewsCount: drift.Value(experience.reviewsCount),
      duration: drift.Value(experience.duration),
      skillsToLearn: drift.Value(jsonEncode(experience.skillsToLearn)),
      skillsToTeach: drift.Value(jsonEncode(experience.skillsToTeach)),
      categories: drift.Value(jsonEncode(experience.categories)),
      languages: drift.Value(jsonEncode(experience.languages)),
      createdAt: drift.Value(experience.createdAt),
      priceCOP: drift.Value(experience.priceCOP),
      groupSizeMax: drift.Value(experience.groupSizeMax),
      paymentOptions: drift.Value(jsonEncode(experience.paymentOptions)),
      images: drift.Value(jsonEncode(experience.images)),
      isActive: drift.Value(experience.isActive),
      accessibilityFeatures:
          drift.Value(jsonEncode(experience.accessibilityFeatures)),
      lastSyncedAt: drift.Value(DateTime.now()),
      isDirty: drift.Value(markDirty),
    );
  }

  /// Convert Drift Experience to Domain Experience model
  static models.Experience experienceFromDrift(Experience driftExperience) {
    return models.Experience(
      id: driftExperience.id,
      title: driftExperience.title,
      summary: driftExperience.summary,
      hostId: driftExperience.hostId,
      hostVerified: driftExperience.hostVerified,
      location: GeoPoint(
        driftExperience.locationLat,
        driftExperience.locationLng,
      ),
      department: driftExperience.department,
      avgRating: driftExperience.avgRating,
      reviewsCount: driftExperience.reviewsCount,
      duration: driftExperience.duration,
      skillsToLearn: _parseStringList(driftExperience.skillsToLearn),
      skillsToTeach: _parseStringList(driftExperience.skillsToTeach),
      categories: _parseStringList(driftExperience.categories),
      languages: _parseStringList(driftExperience.languages),
      createdAt: driftExperience.createdAt,
      priceCOP: driftExperience.priceCOP,
      groupSizeMax: driftExperience.groupSizeMax,
      paymentOptions: _parseStringList(driftExperience.paymentOptions),
      images: _parseStringList(driftExperience.images),
      isActive: driftExperience.isActive,
      accessibilityFeatures:
          _parseStringList(driftExperience.accessibilityFeatures),
    );
  }

  /// Convert Firestore Host to Drift UsersCompanion
  static UsersCompanion hostToCompanion(
    models.Host host, {
    bool markDirty = false,
  }) {
    return UsersCompanion(
      id: drift.Value(host.id),
      name: drift.Value(host.name),
      email: drift.Value(host.email),
      avgHostRating: drift.Value(host.avgHostRating),
      isVerified: drift.Value(host.isVerified),
      memberSince: drift.Value(host.memberSince),
      languages: drift.Value(jsonEncode(host.languages)),
      responseRate: drift.Value(host.responseRate),
      about: drift.Value(host.about),
      hostedExperiences: drift.Value(host.hostedExperiences),
      joinedExperiences: drift.Value(host.joinedExperiences),
      photoURL: drift.Value(host.photoURL),
      lastSyncedAt: drift.Value(DateTime.now()),
      isDirty: drift.Value(markDirty),
    );
  }

  /// Convert Drift User to Domain Host model
  static models.Host hostFromDrift(User driftUser) {
    return models.Host(
      id: driftUser.id,
      name: driftUser.name,
      email: driftUser.email,
      avgHostRating: driftUser.avgHostRating,
      isVerified: driftUser.isVerified,
      memberSince: driftUser.memberSince,
      languages: _parseStringList(driftUser.languages),
      responseRate: driftUser.responseRate,
      about: driftUser.about,
      hostedExperiences: driftUser.hostedExperiences,
      joinedExperiences: driftUser.joinedExperiences,
      photoURL: driftUser.photoURL,
    );
  }

  /// Helper to parse JSON string array back to List<String>
  static List<String> _parseStringList(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return List<String>.from(decoded);
      }
      return [];
    } catch (e) {
      print('Error parsing JSON list: $e');
      return [];
    }
  }
}
