// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExperiencesTable extends Experiences
    with TableInfo<$ExperiencesTable, Experience> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperiencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hostIdMeta = const VerificationMeta('hostId');
  @override
  late final GeneratedColumn<String> hostId = GeneratedColumn<String>(
      'host_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hostVerifiedMeta =
      const VerificationMeta('hostVerified');
  @override
  late final GeneratedColumn<bool> hostVerified = GeneratedColumn<bool>(
      'host_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("host_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _locationLatMeta =
      const VerificationMeta('locationLat');
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
      'location_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _locationLngMeta =
      const VerificationMeta('locationLng');
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
      'location_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avgRatingMeta =
      const VerificationMeta('avgRating');
  @override
  late final GeneratedColumn<double> avgRating = GeneratedColumn<double>(
      'avg_rating', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _reviewsCountMeta =
      const VerificationMeta('reviewsCount');
  @override
  late final GeneratedColumn<int> reviewsCount = GeneratedColumn<int>(
      'reviews_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _skillsToLearnMeta =
      const VerificationMeta('skillsToLearn');
  @override
  late final GeneratedColumn<String> skillsToLearn = GeneratedColumn<String>(
      'skills_to_learn', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skillsToTeachMeta =
      const VerificationMeta('skillsToTeach');
  @override
  late final GeneratedColumn<String> skillsToTeach = GeneratedColumn<String>(
      'skills_to_teach', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoriesMeta =
      const VerificationMeta('categories');
  @override
  late final GeneratedColumn<String> categories = GeneratedColumn<String>(
      'categories', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languagesMeta =
      const VerificationMeta('languages');
  @override
  late final GeneratedColumn<String> languages = GeneratedColumn<String>(
      'languages', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentOptionsMeta =
      const VerificationMeta('paymentOptions');
  @override
  late final GeneratedColumn<String> paymentOptions = GeneratedColumn<String>(
      'payment_options', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accessibilityFeaturesMeta =
      const VerificationMeta('accessibilityFeatures');
  @override
  late final GeneratedColumn<String> accessibilityFeatures =
      GeneratedColumn<String>('accessibility_features', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _priceCOPMeta =
      const VerificationMeta('priceCOP');
  @override
  late final GeneratedColumn<int> priceCOP = GeneratedColumn<int>(
      'price_c_o_p', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _groupSizeMaxMeta =
      const VerificationMeta('groupSizeMax');
  @override
  late final GeneratedColumn<int> groupSizeMax = GeneratedColumn<int>(
      'group_size_max', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        summary,
        hostId,
        hostVerified,
        locationLat,
        locationLng,
        department,
        avgRating,
        reviewsCount,
        duration,
        skillsToLearn,
        skillsToTeach,
        categories,
        languages,
        paymentOptions,
        images,
        accessibilityFeatures,
        createdAt,
        priceCOP,
        groupSizeMax,
        isActive,
        lastSyncedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiences';
  @override
  VerificationContext validateIntegrity(Insertable<Experience> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('host_id')) {
      context.handle(_hostIdMeta,
          hostId.isAcceptableOrUnknown(data['host_id']!, _hostIdMeta));
    } else if (isInserting) {
      context.missing(_hostIdMeta);
    }
    if (data.containsKey('host_verified')) {
      context.handle(
          _hostVerifiedMeta,
          hostVerified.isAcceptableOrUnknown(
              data['host_verified']!, _hostVerifiedMeta));
    }
    if (data.containsKey('location_lat')) {
      context.handle(
          _locationLatMeta,
          locationLat.isAcceptableOrUnknown(
              data['location_lat']!, _locationLatMeta));
    } else if (isInserting) {
      context.missing(_locationLatMeta);
    }
    if (data.containsKey('location_lng')) {
      context.handle(
          _locationLngMeta,
          locationLng.isAcceptableOrUnknown(
              data['location_lng']!, _locationLngMeta));
    } else if (isInserting) {
      context.missing(_locationLngMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    } else if (isInserting) {
      context.missing(_departmentMeta);
    }
    if (data.containsKey('avg_rating')) {
      context.handle(_avgRatingMeta,
          avgRating.isAcceptableOrUnknown(data['avg_rating']!, _avgRatingMeta));
    }
    if (data.containsKey('reviews_count')) {
      context.handle(
          _reviewsCountMeta,
          reviewsCount.isAcceptableOrUnknown(
              data['reviews_count']!, _reviewsCountMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('skills_to_learn')) {
      context.handle(
          _skillsToLearnMeta,
          skillsToLearn.isAcceptableOrUnknown(
              data['skills_to_learn']!, _skillsToLearnMeta));
    } else if (isInserting) {
      context.missing(_skillsToLearnMeta);
    }
    if (data.containsKey('skills_to_teach')) {
      context.handle(
          _skillsToTeachMeta,
          skillsToTeach.isAcceptableOrUnknown(
              data['skills_to_teach']!, _skillsToTeachMeta));
    } else if (isInserting) {
      context.missing(_skillsToTeachMeta);
    }
    if (data.containsKey('categories')) {
      context.handle(
          _categoriesMeta,
          categories.isAcceptableOrUnknown(
              data['categories']!, _categoriesMeta));
    } else if (isInserting) {
      context.missing(_categoriesMeta);
    }
    if (data.containsKey('languages')) {
      context.handle(_languagesMeta,
          languages.isAcceptableOrUnknown(data['languages']!, _languagesMeta));
    } else if (isInserting) {
      context.missing(_languagesMeta);
    }
    if (data.containsKey('payment_options')) {
      context.handle(
          _paymentOptionsMeta,
          paymentOptions.isAcceptableOrUnknown(
              data['payment_options']!, _paymentOptionsMeta));
    } else if (isInserting) {
      context.missing(_paymentOptionsMeta);
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    } else if (isInserting) {
      context.missing(_imagesMeta);
    }
    if (data.containsKey('accessibility_features')) {
      context.handle(
          _accessibilityFeaturesMeta,
          accessibilityFeatures.isAcceptableOrUnknown(
              data['accessibility_features']!, _accessibilityFeaturesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('price_c_o_p')) {
      context.handle(_priceCOPMeta,
          priceCOP.isAcceptableOrUnknown(data['price_c_o_p']!, _priceCOPMeta));
    } else if (isInserting) {
      context.missing(_priceCOPMeta);
    }
    if (data.containsKey('group_size_max')) {
      context.handle(
          _groupSizeMaxMeta,
          groupSizeMax.isAcceptableOrUnknown(
              data['group_size_max']!, _groupSizeMaxMeta));
    } else if (isInserting) {
      context.missing(_groupSizeMaxMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Experience map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Experience(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      hostId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host_id'])!,
      hostVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}host_verified'])!,
      locationLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lat'])!,
      locationLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}location_lng'])!,
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department'])!,
      avgRating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}avg_rating'])!,
      reviewsCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reviews_count'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      skillsToLearn: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}skills_to_learn'])!,
      skillsToTeach: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}skills_to_teach'])!,
      categories: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categories'])!,
      languages: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}languages'])!,
      paymentOptions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payment_options'])!,
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images'])!,
      accessibilityFeatures: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}accessibility_features'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      priceCOP: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_c_o_p'])!,
      groupSizeMax: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_size_max'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $ExperiencesTable createAlias(String alias) {
    return $ExperiencesTable(attachedDatabase, alias);
  }
}

class Experience extends DataClass implements Insertable<Experience> {
  final String id;
  final String title;
  final String summary;
  final String hostId;
  final bool hostVerified;
  final double locationLat;
  final double locationLng;
  final String department;
  final double avgRating;
  final int reviewsCount;
  final int duration;
  final String skillsToLearn;
  final String skillsToTeach;
  final String categories;
  final String languages;
  final String paymentOptions;
  final String images;
  final String accessibilityFeatures;
  final DateTime createdAt;
  final int priceCOP;
  final int groupSizeMax;
  final bool isActive;
  final DateTime? lastSyncedAt;
  final bool isDirty;
  const Experience(
      {required this.id,
      required this.title,
      required this.summary,
      required this.hostId,
      required this.hostVerified,
      required this.locationLat,
      required this.locationLng,
      required this.department,
      required this.avgRating,
      required this.reviewsCount,
      required this.duration,
      required this.skillsToLearn,
      required this.skillsToTeach,
      required this.categories,
      required this.languages,
      required this.paymentOptions,
      required this.images,
      required this.accessibilityFeatures,
      required this.createdAt,
      required this.priceCOP,
      required this.groupSizeMax,
      required this.isActive,
      this.lastSyncedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['host_id'] = Variable<String>(hostId);
    map['host_verified'] = Variable<bool>(hostVerified);
    map['location_lat'] = Variable<double>(locationLat);
    map['location_lng'] = Variable<double>(locationLng);
    map['department'] = Variable<String>(department);
    map['avg_rating'] = Variable<double>(avgRating);
    map['reviews_count'] = Variable<int>(reviewsCount);
    map['duration'] = Variable<int>(duration);
    map['skills_to_learn'] = Variable<String>(skillsToLearn);
    map['skills_to_teach'] = Variable<String>(skillsToTeach);
    map['categories'] = Variable<String>(categories);
    map['languages'] = Variable<String>(languages);
    map['payment_options'] = Variable<String>(paymentOptions);
    map['images'] = Variable<String>(images);
    map['accessibility_features'] = Variable<String>(accessibilityFeatures);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['price_c_o_p'] = Variable<int>(priceCOP);
    map['group_size_max'] = Variable<int>(groupSizeMax);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ExperiencesCompanion toCompanion(bool nullToAbsent) {
    return ExperiencesCompanion(
      id: Value(id),
      title: Value(title),
      summary: Value(summary),
      hostId: Value(hostId),
      hostVerified: Value(hostVerified),
      locationLat: Value(locationLat),
      locationLng: Value(locationLng),
      department: Value(department),
      avgRating: Value(avgRating),
      reviewsCount: Value(reviewsCount),
      duration: Value(duration),
      skillsToLearn: Value(skillsToLearn),
      skillsToTeach: Value(skillsToTeach),
      categories: Value(categories),
      languages: Value(languages),
      paymentOptions: Value(paymentOptions),
      images: Value(images),
      accessibilityFeatures: Value(accessibilityFeatures),
      createdAt: Value(createdAt),
      priceCOP: Value(priceCOP),
      groupSizeMax: Value(groupSizeMax),
      isActive: Value(isActive),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory Experience.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Experience(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      hostId: serializer.fromJson<String>(json['hostId']),
      hostVerified: serializer.fromJson<bool>(json['hostVerified']),
      locationLat: serializer.fromJson<double>(json['locationLat']),
      locationLng: serializer.fromJson<double>(json['locationLng']),
      department: serializer.fromJson<String>(json['department']),
      avgRating: serializer.fromJson<double>(json['avgRating']),
      reviewsCount: serializer.fromJson<int>(json['reviewsCount']),
      duration: serializer.fromJson<int>(json['duration']),
      skillsToLearn: serializer.fromJson<String>(json['skillsToLearn']),
      skillsToTeach: serializer.fromJson<String>(json['skillsToTeach']),
      categories: serializer.fromJson<String>(json['categories']),
      languages: serializer.fromJson<String>(json['languages']),
      paymentOptions: serializer.fromJson<String>(json['paymentOptions']),
      images: serializer.fromJson<String>(json['images']),
      accessibilityFeatures:
          serializer.fromJson<String>(json['accessibilityFeatures']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      priceCOP: serializer.fromJson<int>(json['priceCOP']),
      groupSizeMax: serializer.fromJson<int>(json['groupSizeMax']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'hostId': serializer.toJson<String>(hostId),
      'hostVerified': serializer.toJson<bool>(hostVerified),
      'locationLat': serializer.toJson<double>(locationLat),
      'locationLng': serializer.toJson<double>(locationLng),
      'department': serializer.toJson<String>(department),
      'avgRating': serializer.toJson<double>(avgRating),
      'reviewsCount': serializer.toJson<int>(reviewsCount),
      'duration': serializer.toJson<int>(duration),
      'skillsToLearn': serializer.toJson<String>(skillsToLearn),
      'skillsToTeach': serializer.toJson<String>(skillsToTeach),
      'categories': serializer.toJson<String>(categories),
      'languages': serializer.toJson<String>(languages),
      'paymentOptions': serializer.toJson<String>(paymentOptions),
      'images': serializer.toJson<String>(images),
      'accessibilityFeatures': serializer.toJson<String>(accessibilityFeatures),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'priceCOP': serializer.toJson<int>(priceCOP),
      'groupSizeMax': serializer.toJson<int>(groupSizeMax),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Experience copyWith(
          {String? id,
          String? title,
          String? summary,
          String? hostId,
          bool? hostVerified,
          double? locationLat,
          double? locationLng,
          String? department,
          double? avgRating,
          int? reviewsCount,
          int? duration,
          String? skillsToLearn,
          String? skillsToTeach,
          String? categories,
          String? languages,
          String? paymentOptions,
          String? images,
          String? accessibilityFeatures,
          DateTime? createdAt,
          int? priceCOP,
          int? groupSizeMax,
          bool? isActive,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? isDirty}) =>
      Experience(
        id: id ?? this.id,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        hostId: hostId ?? this.hostId,
        hostVerified: hostVerified ?? this.hostVerified,
        locationLat: locationLat ?? this.locationLat,
        locationLng: locationLng ?? this.locationLng,
        department: department ?? this.department,
        avgRating: avgRating ?? this.avgRating,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        duration: duration ?? this.duration,
        skillsToLearn: skillsToLearn ?? this.skillsToLearn,
        skillsToTeach: skillsToTeach ?? this.skillsToTeach,
        categories: categories ?? this.categories,
        languages: languages ?? this.languages,
        paymentOptions: paymentOptions ?? this.paymentOptions,
        images: images ?? this.images,
        accessibilityFeatures:
            accessibilityFeatures ?? this.accessibilityFeatures,
        createdAt: createdAt ?? this.createdAt,
        priceCOP: priceCOP ?? this.priceCOP,
        groupSizeMax: groupSizeMax ?? this.groupSizeMax,
        isActive: isActive ?? this.isActive,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  Experience copyWithCompanion(ExperiencesCompanion data) {
    return Experience(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      hostId: data.hostId.present ? data.hostId.value : this.hostId,
      hostVerified: data.hostVerified.present
          ? data.hostVerified.value
          : this.hostVerified,
      locationLat:
          data.locationLat.present ? data.locationLat.value : this.locationLat,
      locationLng:
          data.locationLng.present ? data.locationLng.value : this.locationLng,
      department:
          data.department.present ? data.department.value : this.department,
      avgRating: data.avgRating.present ? data.avgRating.value : this.avgRating,
      reviewsCount: data.reviewsCount.present
          ? data.reviewsCount.value
          : this.reviewsCount,
      duration: data.duration.present ? data.duration.value : this.duration,
      skillsToLearn: data.skillsToLearn.present
          ? data.skillsToLearn.value
          : this.skillsToLearn,
      skillsToTeach: data.skillsToTeach.present
          ? data.skillsToTeach.value
          : this.skillsToTeach,
      categories:
          data.categories.present ? data.categories.value : this.categories,
      languages: data.languages.present ? data.languages.value : this.languages,
      paymentOptions: data.paymentOptions.present
          ? data.paymentOptions.value
          : this.paymentOptions,
      images: data.images.present ? data.images.value : this.images,
      accessibilityFeatures: data.accessibilityFeatures.present
          ? data.accessibilityFeatures.value
          : this.accessibilityFeatures,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      priceCOP: data.priceCOP.present ? data.priceCOP.value : this.priceCOP,
      groupSizeMax: data.groupSizeMax.present
          ? data.groupSizeMax.value
          : this.groupSizeMax,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Experience(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('hostId: $hostId, ')
          ..write('hostVerified: $hostVerified, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('department: $department, ')
          ..write('avgRating: $avgRating, ')
          ..write('reviewsCount: $reviewsCount, ')
          ..write('duration: $duration, ')
          ..write('skillsToLearn: $skillsToLearn, ')
          ..write('skillsToTeach: $skillsToTeach, ')
          ..write('categories: $categories, ')
          ..write('languages: $languages, ')
          ..write('paymentOptions: $paymentOptions, ')
          ..write('images: $images, ')
          ..write('accessibilityFeatures: $accessibilityFeatures, ')
          ..write('createdAt: $createdAt, ')
          ..write('priceCOP: $priceCOP, ')
          ..write('groupSizeMax: $groupSizeMax, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        summary,
        hostId,
        hostVerified,
        locationLat,
        locationLng,
        department,
        avgRating,
        reviewsCount,
        duration,
        skillsToLearn,
        skillsToTeach,
        categories,
        languages,
        paymentOptions,
        images,
        accessibilityFeatures,
        createdAt,
        priceCOP,
        groupSizeMax,
        isActive,
        lastSyncedAt,
        isDirty
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Experience &&
          other.id == this.id &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.hostId == this.hostId &&
          other.hostVerified == this.hostVerified &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.department == this.department &&
          other.avgRating == this.avgRating &&
          other.reviewsCount == this.reviewsCount &&
          other.duration == this.duration &&
          other.skillsToLearn == this.skillsToLearn &&
          other.skillsToTeach == this.skillsToTeach &&
          other.categories == this.categories &&
          other.languages == this.languages &&
          other.paymentOptions == this.paymentOptions &&
          other.images == this.images &&
          other.accessibilityFeatures == this.accessibilityFeatures &&
          other.createdAt == this.createdAt &&
          other.priceCOP == this.priceCOP &&
          other.groupSizeMax == this.groupSizeMax &&
          other.isActive == this.isActive &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.isDirty == this.isDirty);
}

class ExperiencesCompanion extends UpdateCompanion<Experience> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> summary;
  final Value<String> hostId;
  final Value<bool> hostVerified;
  final Value<double> locationLat;
  final Value<double> locationLng;
  final Value<String> department;
  final Value<double> avgRating;
  final Value<int> reviewsCount;
  final Value<int> duration;
  final Value<String> skillsToLearn;
  final Value<String> skillsToTeach;
  final Value<String> categories;
  final Value<String> languages;
  final Value<String> paymentOptions;
  final Value<String> images;
  final Value<String> accessibilityFeatures;
  final Value<DateTime> createdAt;
  final Value<int> priceCOP;
  final Value<int> groupSizeMax;
  final Value<bool> isActive;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ExperiencesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.hostId = const Value.absent(),
    this.hostVerified = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.department = const Value.absent(),
    this.avgRating = const Value.absent(),
    this.reviewsCount = const Value.absent(),
    this.duration = const Value.absent(),
    this.skillsToLearn = const Value.absent(),
    this.skillsToTeach = const Value.absent(),
    this.categories = const Value.absent(),
    this.languages = const Value.absent(),
    this.paymentOptions = const Value.absent(),
    this.images = const Value.absent(),
    this.accessibilityFeatures = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.priceCOP = const Value.absent(),
    this.groupSizeMax = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperiencesCompanion.insert({
    required String id,
    required String title,
    required String summary,
    required String hostId,
    this.hostVerified = const Value.absent(),
    required double locationLat,
    required double locationLng,
    required String department,
    this.avgRating = const Value.absent(),
    this.reviewsCount = const Value.absent(),
    required int duration,
    required String skillsToLearn,
    required String skillsToTeach,
    required String categories,
    required String languages,
    required String paymentOptions,
    required String images,
    this.accessibilityFeatures = const Value.absent(),
    required DateTime createdAt,
    required int priceCOP,
    required int groupSizeMax,
    this.isActive = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        summary = Value(summary),
        hostId = Value(hostId),
        locationLat = Value(locationLat),
        locationLng = Value(locationLng),
        department = Value(department),
        duration = Value(duration),
        skillsToLearn = Value(skillsToLearn),
        skillsToTeach = Value(skillsToTeach),
        categories = Value(categories),
        languages = Value(languages),
        paymentOptions = Value(paymentOptions),
        images = Value(images),
        createdAt = Value(createdAt),
        priceCOP = Value(priceCOP),
        groupSizeMax = Value(groupSizeMax);
  static Insertable<Experience> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? hostId,
    Expression<bool>? hostVerified,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<String>? department,
    Expression<double>? avgRating,
    Expression<int>? reviewsCount,
    Expression<int>? duration,
    Expression<String>? skillsToLearn,
    Expression<String>? skillsToTeach,
    Expression<String>? categories,
    Expression<String>? languages,
    Expression<String>? paymentOptions,
    Expression<String>? images,
    Expression<String>? accessibilityFeatures,
    Expression<DateTime>? createdAt,
    Expression<int>? priceCOP,
    Expression<int>? groupSizeMax,
    Expression<bool>? isActive,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (hostId != null) 'host_id': hostId,
      if (hostVerified != null) 'host_verified': hostVerified,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (department != null) 'department': department,
      if (avgRating != null) 'avg_rating': avgRating,
      if (reviewsCount != null) 'reviews_count': reviewsCount,
      if (duration != null) 'duration': duration,
      if (skillsToLearn != null) 'skills_to_learn': skillsToLearn,
      if (skillsToTeach != null) 'skills_to_teach': skillsToTeach,
      if (categories != null) 'categories': categories,
      if (languages != null) 'languages': languages,
      if (paymentOptions != null) 'payment_options': paymentOptions,
      if (images != null) 'images': images,
      if (accessibilityFeatures != null)
        'accessibility_features': accessibilityFeatures,
      if (createdAt != null) 'created_at': createdAt,
      if (priceCOP != null) 'price_c_o_p': priceCOP,
      if (groupSizeMax != null) 'group_size_max': groupSizeMax,
      if (isActive != null) 'is_active': isActive,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperiencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? summary,
      Value<String>? hostId,
      Value<bool>? hostVerified,
      Value<double>? locationLat,
      Value<double>? locationLng,
      Value<String>? department,
      Value<double>? avgRating,
      Value<int>? reviewsCount,
      Value<int>? duration,
      Value<String>? skillsToLearn,
      Value<String>? skillsToTeach,
      Value<String>? categories,
      Value<String>? languages,
      Value<String>? paymentOptions,
      Value<String>? images,
      Value<String>? accessibilityFeatures,
      Value<DateTime>? createdAt,
      Value<int>? priceCOP,
      Value<int>? groupSizeMax,
      Value<bool>? isActive,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return ExperiencesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      hostId: hostId ?? this.hostId,
      hostVerified: hostVerified ?? this.hostVerified,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      department: department ?? this.department,
      avgRating: avgRating ?? this.avgRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      duration: duration ?? this.duration,
      skillsToLearn: skillsToLearn ?? this.skillsToLearn,
      skillsToTeach: skillsToTeach ?? this.skillsToTeach,
      categories: categories ?? this.categories,
      languages: languages ?? this.languages,
      paymentOptions: paymentOptions ?? this.paymentOptions,
      images: images ?? this.images,
      accessibilityFeatures:
          accessibilityFeatures ?? this.accessibilityFeatures,
      createdAt: createdAt ?? this.createdAt,
      priceCOP: priceCOP ?? this.priceCOP,
      groupSizeMax: groupSizeMax ?? this.groupSizeMax,
      isActive: isActive ?? this.isActive,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (hostId.present) {
      map['host_id'] = Variable<String>(hostId.value);
    }
    if (hostVerified.present) {
      map['host_verified'] = Variable<bool>(hostVerified.value);
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (avgRating.present) {
      map['avg_rating'] = Variable<double>(avgRating.value);
    }
    if (reviewsCount.present) {
      map['reviews_count'] = Variable<int>(reviewsCount.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (skillsToLearn.present) {
      map['skills_to_learn'] = Variable<String>(skillsToLearn.value);
    }
    if (skillsToTeach.present) {
      map['skills_to_teach'] = Variable<String>(skillsToTeach.value);
    }
    if (categories.present) {
      map['categories'] = Variable<String>(categories.value);
    }
    if (languages.present) {
      map['languages'] = Variable<String>(languages.value);
    }
    if (paymentOptions.present) {
      map['payment_options'] = Variable<String>(paymentOptions.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (accessibilityFeatures.present) {
      map['accessibility_features'] =
          Variable<String>(accessibilityFeatures.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (priceCOP.present) {
      map['price_c_o_p'] = Variable<int>(priceCOP.value);
    }
    if (groupSizeMax.present) {
      map['group_size_max'] = Variable<int>(groupSizeMax.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperiencesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('hostId: $hostId, ')
          ..write('hostVerified: $hostVerified, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('department: $department, ')
          ..write('avgRating: $avgRating, ')
          ..write('reviewsCount: $reviewsCount, ')
          ..write('duration: $duration, ')
          ..write('skillsToLearn: $skillsToLearn, ')
          ..write('skillsToTeach: $skillsToTeach, ')
          ..write('categories: $categories, ')
          ..write('languages: $languages, ')
          ..write('paymentOptions: $paymentOptions, ')
          ..write('images: $images, ')
          ..write('accessibilityFeatures: $accessibilityFeatures, ')
          ..write('createdAt: $createdAt, ')
          ..write('priceCOP: $priceCOP, ')
          ..write('groupSizeMax: $groupSizeMax, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avgHostRatingMeta =
      const VerificationMeta('avgHostRating');
  @override
  late final GeneratedColumn<double> avgHostRating = GeneratedColumn<double>(
      'avg_host_rating', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _memberSinceMeta =
      const VerificationMeta('memberSince');
  @override
  late final GeneratedColumn<DateTime> memberSince = GeneratedColumn<DateTime>(
      'member_since', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _languagesMeta =
      const VerificationMeta('languages');
  @override
  late final GeneratedColumn<String> languages = GeneratedColumn<String>(
      'languages', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseRateMeta =
      const VerificationMeta('responseRate');
  @override
  late final GeneratedColumn<String> responseRate = GeneratedColumn<String>(
      'response_rate', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('N/A'));
  static const VerificationMeta _aboutMeta = const VerificationMeta('about');
  @override
  late final GeneratedColumn<String> about = GeneratedColumn<String>(
      'about', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Tell others about yourself.'));
  static const VerificationMeta _hostedExperiencesMeta =
      const VerificationMeta('hostedExperiences');
  @override
  late final GeneratedColumn<int> hostedExperiences = GeneratedColumn<int>(
      'hosted_experiences', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _joinedExperiencesMeta =
      const VerificationMeta('joinedExperiences');
  @override
  late final GeneratedColumn<int> joinedExperiences = GeneratedColumn<int>(
      'joined_experiences', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _photoURLMeta =
      const VerificationMeta('photoURL');
  @override
  late final GeneratedColumn<String> photoURL = GeneratedColumn<String>(
      'photo_u_r_l', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        email,
        avgHostRating,
        isVerified,
        memberSince,
        languages,
        responseRate,
        about,
        hostedExperiences,
        joinedExperiences,
        photoURL,
        lastSyncedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('avg_host_rating')) {
      context.handle(
          _avgHostRatingMeta,
          avgHostRating.isAcceptableOrUnknown(
              data['avg_host_rating']!, _avgHostRatingMeta));
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    }
    if (data.containsKey('member_since')) {
      context.handle(
          _memberSinceMeta,
          memberSince.isAcceptableOrUnknown(
              data['member_since']!, _memberSinceMeta));
    } else if (isInserting) {
      context.missing(_memberSinceMeta);
    }
    if (data.containsKey('languages')) {
      context.handle(_languagesMeta,
          languages.isAcceptableOrUnknown(data['languages']!, _languagesMeta));
    } else if (isInserting) {
      context.missing(_languagesMeta);
    }
    if (data.containsKey('response_rate')) {
      context.handle(
          _responseRateMeta,
          responseRate.isAcceptableOrUnknown(
              data['response_rate']!, _responseRateMeta));
    }
    if (data.containsKey('about')) {
      context.handle(
          _aboutMeta, about.isAcceptableOrUnknown(data['about']!, _aboutMeta));
    }
    if (data.containsKey('hosted_experiences')) {
      context.handle(
          _hostedExperiencesMeta,
          hostedExperiences.isAcceptableOrUnknown(
              data['hosted_experiences']!, _hostedExperiencesMeta));
    }
    if (data.containsKey('joined_experiences')) {
      context.handle(
          _joinedExperiencesMeta,
          joinedExperiences.isAcceptableOrUnknown(
              data['joined_experiences']!, _joinedExperiencesMeta));
    }
    if (data.containsKey('photo_u_r_l')) {
      context.handle(_photoURLMeta,
          photoURL.isAcceptableOrUnknown(data['photo_u_r_l']!, _photoURLMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      avgHostRating: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}avg_host_rating'])!,
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verified'])!,
      memberSince: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}member_since'])!,
      languages: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}languages'])!,
      responseRate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_rate'])!,
      about: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}about'])!,
      hostedExperiences: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}hosted_experiences'])!,
      joinedExperiences: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}joined_experiences'])!,
      photoURL: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_u_r_l']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String name;
  final String email;
  final double avgHostRating;
  final bool isVerified;
  final DateTime memberSince;
  final String languages;
  final String responseRate;
  final String about;
  final int hostedExperiences;
  final int joinedExperiences;
  final String? photoURL;
  final DateTime? lastSyncedAt;
  final bool isDirty;
  const User(
      {required this.id,
      required this.name,
      required this.email,
      required this.avgHostRating,
      required this.isVerified,
      required this.memberSince,
      required this.languages,
      required this.responseRate,
      required this.about,
      required this.hostedExperiences,
      required this.joinedExperiences,
      this.photoURL,
      this.lastSyncedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['avg_host_rating'] = Variable<double>(avgHostRating);
    map['is_verified'] = Variable<bool>(isVerified);
    map['member_since'] = Variable<DateTime>(memberSince);
    map['languages'] = Variable<String>(languages);
    map['response_rate'] = Variable<String>(responseRate);
    map['about'] = Variable<String>(about);
    map['hosted_experiences'] = Variable<int>(hostedExperiences);
    map['joined_experiences'] = Variable<int>(joinedExperiences);
    if (!nullToAbsent || photoURL != null) {
      map['photo_u_r_l'] = Variable<String>(photoURL);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      avgHostRating: Value(avgHostRating),
      isVerified: Value(isVerified),
      memberSince: Value(memberSince),
      languages: Value(languages),
      responseRate: Value(responseRate),
      about: Value(about),
      hostedExperiences: Value(hostedExperiences),
      joinedExperiences: Value(joinedExperiences),
      photoURL: photoURL == null && nullToAbsent
          ? const Value.absent()
          : Value(photoURL),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      avgHostRating: serializer.fromJson<double>(json['avgHostRating']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      memberSince: serializer.fromJson<DateTime>(json['memberSince']),
      languages: serializer.fromJson<String>(json['languages']),
      responseRate: serializer.fromJson<String>(json['responseRate']),
      about: serializer.fromJson<String>(json['about']),
      hostedExperiences: serializer.fromJson<int>(json['hostedExperiences']),
      joinedExperiences: serializer.fromJson<int>(json['joinedExperiences']),
      photoURL: serializer.fromJson<String?>(json['photoURL']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'avgHostRating': serializer.toJson<double>(avgHostRating),
      'isVerified': serializer.toJson<bool>(isVerified),
      'memberSince': serializer.toJson<DateTime>(memberSince),
      'languages': serializer.toJson<String>(languages),
      'responseRate': serializer.toJson<String>(responseRate),
      'about': serializer.toJson<String>(about),
      'hostedExperiences': serializer.toJson<int>(hostedExperiences),
      'joinedExperiences': serializer.toJson<int>(joinedExperiences),
      'photoURL': serializer.toJson<String?>(photoURL),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  User copyWith(
          {String? id,
          String? name,
          String? email,
          double? avgHostRating,
          bool? isVerified,
          DateTime? memberSince,
          String? languages,
          String? responseRate,
          String? about,
          int? hostedExperiences,
          int? joinedExperiences,
          Value<String?> photoURL = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? isDirty}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avgHostRating: avgHostRating ?? this.avgHostRating,
        isVerified: isVerified ?? this.isVerified,
        memberSince: memberSince ?? this.memberSince,
        languages: languages ?? this.languages,
        responseRate: responseRate ?? this.responseRate,
        about: about ?? this.about,
        hostedExperiences: hostedExperiences ?? this.hostedExperiences,
        joinedExperiences: joinedExperiences ?? this.joinedExperiences,
        photoURL: photoURL.present ? photoURL.value : this.photoURL,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      avgHostRating: data.avgHostRating.present
          ? data.avgHostRating.value
          : this.avgHostRating,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      memberSince:
          data.memberSince.present ? data.memberSince.value : this.memberSince,
      languages: data.languages.present ? data.languages.value : this.languages,
      responseRate: data.responseRate.present
          ? data.responseRate.value
          : this.responseRate,
      about: data.about.present ? data.about.value : this.about,
      hostedExperiences: data.hostedExperiences.present
          ? data.hostedExperiences.value
          : this.hostedExperiences,
      joinedExperiences: data.joinedExperiences.present
          ? data.joinedExperiences.value
          : this.joinedExperiences,
      photoURL: data.photoURL.present ? data.photoURL.value : this.photoURL,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('avgHostRating: $avgHostRating, ')
          ..write('isVerified: $isVerified, ')
          ..write('memberSince: $memberSince, ')
          ..write('languages: $languages, ')
          ..write('responseRate: $responseRate, ')
          ..write('about: $about, ')
          ..write('hostedExperiences: $hostedExperiences, ')
          ..write('joinedExperiences: $joinedExperiences, ')
          ..write('photoURL: $photoURL, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      email,
      avgHostRating,
      isVerified,
      memberSince,
      languages,
      responseRate,
      about,
      hostedExperiences,
      joinedExperiences,
      photoURL,
      lastSyncedAt,
      isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.avgHostRating == this.avgHostRating &&
          other.isVerified == this.isVerified &&
          other.memberSince == this.memberSince &&
          other.languages == this.languages &&
          other.responseRate == this.responseRate &&
          other.about == this.about &&
          other.hostedExperiences == this.hostedExperiences &&
          other.joinedExperiences == this.joinedExperiences &&
          other.photoURL == this.photoURL &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.isDirty == this.isDirty);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<double> avgHostRating;
  final Value<bool> isVerified;
  final Value<DateTime> memberSince;
  final Value<String> languages;
  final Value<String> responseRate;
  final Value<String> about;
  final Value<int> hostedExperiences;
  final Value<int> joinedExperiences;
  final Value<String?> photoURL;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.avgHostRating = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.memberSince = const Value.absent(),
    this.languages = const Value.absent(),
    this.responseRate = const Value.absent(),
    this.about = const Value.absent(),
    this.hostedExperiences = const Value.absent(),
    this.joinedExperiences = const Value.absent(),
    this.photoURL = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.avgHostRating = const Value.absent(),
    this.isVerified = const Value.absent(),
    required DateTime memberSince,
    required String languages,
    this.responseRate = const Value.absent(),
    this.about = const Value.absent(),
    this.hostedExperiences = const Value.absent(),
    this.joinedExperiences = const Value.absent(),
    this.photoURL = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        email = Value(email),
        memberSince = Value(memberSince),
        languages = Value(languages);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<double>? avgHostRating,
    Expression<bool>? isVerified,
    Expression<DateTime>? memberSince,
    Expression<String>? languages,
    Expression<String>? responseRate,
    Expression<String>? about,
    Expression<int>? hostedExperiences,
    Expression<int>? joinedExperiences,
    Expression<String>? photoURL,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avgHostRating != null) 'avg_host_rating': avgHostRating,
      if (isVerified != null) 'is_verified': isVerified,
      if (memberSince != null) 'member_since': memberSince,
      if (languages != null) 'languages': languages,
      if (responseRate != null) 'response_rate': responseRate,
      if (about != null) 'about': about,
      if (hostedExperiences != null) 'hosted_experiences': hostedExperiences,
      if (joinedExperiences != null) 'joined_experiences': joinedExperiences,
      if (photoURL != null) 'photo_u_r_l': photoURL,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? email,
      Value<double>? avgHostRating,
      Value<bool>? isVerified,
      Value<DateTime>? memberSince,
      Value<String>? languages,
      Value<String>? responseRate,
      Value<String>? about,
      Value<int>? hostedExperiences,
      Value<int>? joinedExperiences,
      Value<String?>? photoURL,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avgHostRating: avgHostRating ?? this.avgHostRating,
      isVerified: isVerified ?? this.isVerified,
      memberSince: memberSince ?? this.memberSince,
      languages: languages ?? this.languages,
      responseRate: responseRate ?? this.responseRate,
      about: about ?? this.about,
      hostedExperiences: hostedExperiences ?? this.hostedExperiences,
      joinedExperiences: joinedExperiences ?? this.joinedExperiences,
      photoURL: photoURL ?? this.photoURL,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (avgHostRating.present) {
      map['avg_host_rating'] = Variable<double>(avgHostRating.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (memberSince.present) {
      map['member_since'] = Variable<DateTime>(memberSince.value);
    }
    if (languages.present) {
      map['languages'] = Variable<String>(languages.value);
    }
    if (responseRate.present) {
      map['response_rate'] = Variable<String>(responseRate.value);
    }
    if (about.present) {
      map['about'] = Variable<String>(about.value);
    }
    if (hostedExperiences.present) {
      map['hosted_experiences'] = Variable<int>(hostedExperiences.value);
    }
    if (joinedExperiences.present) {
      map['joined_experiences'] = Variable<int>(joinedExperiences.value);
    }
    if (photoURL.present) {
      map['photo_u_r_l'] = Variable<String>(photoURL.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('avgHostRating: $avgHostRating, ')
          ..write('isVerified: $isVerified, ')
          ..write('memberSince: $memberSince, ')
          ..write('languages: $languages, ')
          ..write('responseRate: $responseRate, ')
          ..write('about: $about, ')
          ..write('hostedExperiences: $hostedExperiences, ')
          ..write('joinedExperiences: $joinedExperiences, ')
          ..write('photoURL: $photoURL, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExperiencesTable experiences = $ExperiencesTable(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [experiences, users];
}

typedef $$ExperiencesTableCreateCompanionBuilder = ExperiencesCompanion
    Function({
  required String id,
  required String title,
  required String summary,
  required String hostId,
  Value<bool> hostVerified,
  required double locationLat,
  required double locationLng,
  required String department,
  Value<double> avgRating,
  Value<int> reviewsCount,
  required int duration,
  required String skillsToLearn,
  required String skillsToTeach,
  required String categories,
  required String languages,
  required String paymentOptions,
  required String images,
  Value<String> accessibilityFeatures,
  required DateTime createdAt,
  required int priceCOP,
  required int groupSizeMax,
  Value<bool> isActive,
  Value<DateTime?> lastSyncedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$ExperiencesTableUpdateCompanionBuilder = ExperiencesCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> summary,
  Value<String> hostId,
  Value<bool> hostVerified,
  Value<double> locationLat,
  Value<double> locationLng,
  Value<String> department,
  Value<double> avgRating,
  Value<int> reviewsCount,
  Value<int> duration,
  Value<String> skillsToLearn,
  Value<String> skillsToTeach,
  Value<String> categories,
  Value<String> languages,
  Value<String> paymentOptions,
  Value<String> images,
  Value<String> accessibilityFeatures,
  Value<DateTime> createdAt,
  Value<int> priceCOP,
  Value<int> groupSizeMax,
  Value<bool> isActive,
  Value<DateTime?> lastSyncedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$ExperiencesTableFilterComposer
    extends Composer<_$AppDatabase, $ExperiencesTable> {
  $$ExperiencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hostId => $composableBuilder(
      column: $table.hostId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hostVerified => $composableBuilder(
      column: $table.hostVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgRating => $composableBuilder(
      column: $table.avgRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewsCount => $composableBuilder(
      column: $table.reviewsCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get skillsToLearn => $composableBuilder(
      column: $table.skillsToLearn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get skillsToTeach => $composableBuilder(
      column: $table.skillsToTeach, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categories => $composableBuilder(
      column: $table.categories, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languages => $composableBuilder(
      column: $table.languages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentOptions => $composableBuilder(
      column: $table.paymentOptions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessibilityFeatures => $composableBuilder(
      column: $table.accessibilityFeatures,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priceCOP => $composableBuilder(
      column: $table.priceCOP, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groupSizeMax => $composableBuilder(
      column: $table.groupSizeMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$ExperiencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperiencesTable> {
  $$ExperiencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hostId => $composableBuilder(
      column: $table.hostId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hostVerified => $composableBuilder(
      column: $table.hostVerified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgRating => $composableBuilder(
      column: $table.avgRating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewsCount => $composableBuilder(
      column: $table.reviewsCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get skillsToLearn => $composableBuilder(
      column: $table.skillsToLearn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get skillsToTeach => $composableBuilder(
      column: $table.skillsToTeach,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categories => $composableBuilder(
      column: $table.categories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languages => $composableBuilder(
      column: $table.languages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentOptions => $composableBuilder(
      column: $table.paymentOptions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get images => $composableBuilder(
      column: $table.images, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessibilityFeatures => $composableBuilder(
      column: $table.accessibilityFeatures,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priceCOP => $composableBuilder(
      column: $table.priceCOP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groupSizeMax => $composableBuilder(
      column: $table.groupSizeMax,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$ExperiencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperiencesTable> {
  $$ExperiencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get hostId =>
      $composableBuilder(column: $table.hostId, builder: (column) => column);

  GeneratedColumn<bool> get hostVerified => $composableBuilder(
      column: $table.hostVerified, builder: (column) => column);

  GeneratedColumn<double> get locationLat => $composableBuilder(
      column: $table.locationLat, builder: (column) => column);

  GeneratedColumn<double> get locationLng => $composableBuilder(
      column: $table.locationLng, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<double> get avgRating =>
      $composableBuilder(column: $table.avgRating, builder: (column) => column);

  GeneratedColumn<int> get reviewsCount => $composableBuilder(
      column: $table.reviewsCount, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get skillsToLearn => $composableBuilder(
      column: $table.skillsToLearn, builder: (column) => column);

  GeneratedColumn<String> get skillsToTeach => $composableBuilder(
      column: $table.skillsToTeach, builder: (column) => column);

  GeneratedColumn<String> get categories => $composableBuilder(
      column: $table.categories, builder: (column) => column);

  GeneratedColumn<String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumn<String> get paymentOptions => $composableBuilder(
      column: $table.paymentOptions, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get accessibilityFeatures => $composableBuilder(
      column: $table.accessibilityFeatures, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get priceCOP =>
      $composableBuilder(column: $table.priceCOP, builder: (column) => column);

  GeneratedColumn<int> get groupSizeMax => $composableBuilder(
      column: $table.groupSizeMax, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$ExperiencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExperiencesTable,
    Experience,
    $$ExperiencesTableFilterComposer,
    $$ExperiencesTableOrderingComposer,
    $$ExperiencesTableAnnotationComposer,
    $$ExperiencesTableCreateCompanionBuilder,
    $$ExperiencesTableUpdateCompanionBuilder,
    (Experience, BaseReferences<_$AppDatabase, $ExperiencesTable, Experience>),
    Experience,
    PrefetchHooks Function()> {
  $$ExperiencesTableTableManager(_$AppDatabase db, $ExperiencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperiencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperiencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperiencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> hostId = const Value.absent(),
            Value<bool> hostVerified = const Value.absent(),
            Value<double> locationLat = const Value.absent(),
            Value<double> locationLng = const Value.absent(),
            Value<String> department = const Value.absent(),
            Value<double> avgRating = const Value.absent(),
            Value<int> reviewsCount = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<String> skillsToLearn = const Value.absent(),
            Value<String> skillsToTeach = const Value.absent(),
            Value<String> categories = const Value.absent(),
            Value<String> languages = const Value.absent(),
            Value<String> paymentOptions = const Value.absent(),
            Value<String> images = const Value.absent(),
            Value<String> accessibilityFeatures = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> priceCOP = const Value.absent(),
            Value<int> groupSizeMax = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExperiencesCompanion(
            id: id,
            title: title,
            summary: summary,
            hostId: hostId,
            hostVerified: hostVerified,
            locationLat: locationLat,
            locationLng: locationLng,
            department: department,
            avgRating: avgRating,
            reviewsCount: reviewsCount,
            duration: duration,
            skillsToLearn: skillsToLearn,
            skillsToTeach: skillsToTeach,
            categories: categories,
            languages: languages,
            paymentOptions: paymentOptions,
            images: images,
            accessibilityFeatures: accessibilityFeatures,
            createdAt: createdAt,
            priceCOP: priceCOP,
            groupSizeMax: groupSizeMax,
            isActive: isActive,
            lastSyncedAt: lastSyncedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String summary,
            required String hostId,
            Value<bool> hostVerified = const Value.absent(),
            required double locationLat,
            required double locationLng,
            required String department,
            Value<double> avgRating = const Value.absent(),
            Value<int> reviewsCount = const Value.absent(),
            required int duration,
            required String skillsToLearn,
            required String skillsToTeach,
            required String categories,
            required String languages,
            required String paymentOptions,
            required String images,
            Value<String> accessibilityFeatures = const Value.absent(),
            required DateTime createdAt,
            required int priceCOP,
            required int groupSizeMax,
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExperiencesCompanion.insert(
            id: id,
            title: title,
            summary: summary,
            hostId: hostId,
            hostVerified: hostVerified,
            locationLat: locationLat,
            locationLng: locationLng,
            department: department,
            avgRating: avgRating,
            reviewsCount: reviewsCount,
            duration: duration,
            skillsToLearn: skillsToLearn,
            skillsToTeach: skillsToTeach,
            categories: categories,
            languages: languages,
            paymentOptions: paymentOptions,
            images: images,
            accessibilityFeatures: accessibilityFeatures,
            createdAt: createdAt,
            priceCOP: priceCOP,
            groupSizeMax: groupSizeMax,
            isActive: isActive,
            lastSyncedAt: lastSyncedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExperiencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExperiencesTable,
    Experience,
    $$ExperiencesTableFilterComposer,
    $$ExperiencesTableOrderingComposer,
    $$ExperiencesTableAnnotationComposer,
    $$ExperiencesTableCreateCompanionBuilder,
    $$ExperiencesTableUpdateCompanionBuilder,
    (Experience, BaseReferences<_$AppDatabase, $ExperiencesTable, Experience>),
    Experience,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String name,
  required String email,
  Value<double> avgHostRating,
  Value<bool> isVerified,
  required DateTime memberSince,
  required String languages,
  Value<String> responseRate,
  Value<String> about,
  Value<int> hostedExperiences,
  Value<int> joinedExperiences,
  Value<String?> photoURL,
  Value<DateTime?> lastSyncedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> email,
  Value<double> avgHostRating,
  Value<bool> isVerified,
  Value<DateTime> memberSince,
  Value<String> languages,
  Value<String> responseRate,
  Value<String> about,
  Value<int> hostedExperiences,
  Value<int> joinedExperiences,
  Value<String?> photoURL,
  Value<DateTime?> lastSyncedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgHostRating => $composableBuilder(
      column: $table.avgHostRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get memberSince => $composableBuilder(
      column: $table.memberSince, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languages => $composableBuilder(
      column: $table.languages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseRate => $composableBuilder(
      column: $table.responseRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get about => $composableBuilder(
      column: $table.about, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hostedExperiences => $composableBuilder(
      column: $table.hostedExperiences,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedExperiences => $composableBuilder(
      column: $table.joinedExperiences,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoURL => $composableBuilder(
      column: $table.photoURL, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgHostRating => $composableBuilder(
      column: $table.avgHostRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get memberSince => $composableBuilder(
      column: $table.memberSince, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languages => $composableBuilder(
      column: $table.languages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseRate => $composableBuilder(
      column: $table.responseRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get about => $composableBuilder(
      column: $table.about, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hostedExperiences => $composableBuilder(
      column: $table.hostedExperiences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedExperiences => $composableBuilder(
      column: $table.joinedExperiences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoURL => $composableBuilder(
      column: $table.photoURL, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<double> get avgHostRating => $composableBuilder(
      column: $table.avgHostRating, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => column);

  GeneratedColumn<DateTime> get memberSince => $composableBuilder(
      column: $table.memberSince, builder: (column) => column);

  GeneratedColumn<String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumn<String> get responseRate => $composableBuilder(
      column: $table.responseRate, builder: (column) => column);

  GeneratedColumn<String> get about =>
      $composableBuilder(column: $table.about, builder: (column) => column);

  GeneratedColumn<int> get hostedExperiences => $composableBuilder(
      column: $table.hostedExperiences, builder: (column) => column);

  GeneratedColumn<int> get joinedExperiences => $composableBuilder(
      column: $table.joinedExperiences, builder: (column) => column);

  GeneratedColumn<String> get photoURL =>
      $composableBuilder(column: $table.photoURL, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<double> avgHostRating = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<DateTime> memberSince = const Value.absent(),
            Value<String> languages = const Value.absent(),
            Value<String> responseRate = const Value.absent(),
            Value<String> about = const Value.absent(),
            Value<int> hostedExperiences = const Value.absent(),
            Value<int> joinedExperiences = const Value.absent(),
            Value<String?> photoURL = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            email: email,
            avgHostRating: avgHostRating,
            isVerified: isVerified,
            memberSince: memberSince,
            languages: languages,
            responseRate: responseRate,
            about: about,
            hostedExperiences: hostedExperiences,
            joinedExperiences: joinedExperiences,
            photoURL: photoURL,
            lastSyncedAt: lastSyncedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String email,
            Value<double> avgHostRating = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            required DateTime memberSince,
            required String languages,
            Value<String> responseRate = const Value.absent(),
            Value<String> about = const Value.absent(),
            Value<int> hostedExperiences = const Value.absent(),
            Value<int> joinedExperiences = const Value.absent(),
            Value<String?> photoURL = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            avgHostRating: avgHostRating,
            isVerified: isVerified,
            memberSince: memberSince,
            languages: languages,
            responseRate: responseRate,
            about: about,
            hostedExperiences: hostedExperiences,
            joinedExperiences: joinedExperiences,
            photoURL: photoURL,
            lastSyncedAt: lastSyncedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExperiencesTableTableManager get experiences =>
      $$ExperiencesTableTableManager(_db, _db.experiences);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
