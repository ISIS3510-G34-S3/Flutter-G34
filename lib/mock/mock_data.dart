/// Mock data models and providers for TravelConnect app
class Host {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final DateTime memberSince;
  final List<String> languages;
  final String responseRate;
  final String about;
  final int hostedExperiences;
  final int joinedExperiences;

  const Host({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.memberSince,
    required this.languages,
    required this.responseRate,
    required this.about,
    required this.hostedExperiences,
    required this.joinedExperiences,
  });
}

class Experience {
  final String id;
  final String title;
  final String summary;
  final String hostId;
  final bool hostVerified;
  final Map<String, double> location;
  final String department;
  final double avgRating;
  final int reviewsCount;
  final int duration;
  final List<String> skillsToLearn;
  final List<String> skillsToTeach;
  final List<String> categories;
  final DateTime createdAt;
  final int priceCOP;
  final int groupSizeMax;
  final List<String> paymentOptions;
  final bool isActive;

  const Experience({
    required this.id,
    required this.title,
    required this.summary,
    required this.hostId,
    required this.hostVerified,
    required this.location,
    required this.department,
    required this.avgRating,
    required this.reviewsCount,
    required this.duration,
    required this.skillsToLearn,
    required this.skillsToTeach,
    required this.categories,
    required this.createdAt,
    required this.priceCOP,
    required this.groupSizeMax,
    required this.paymentOptions,
    required this.isActive,
  });

  // Helper to get host object
  Host? get host {
    return MockData.getHostById(hostId);
  }

  // Safe helper methods for host data with fallbacks
  String get hostName {
    final hostData = MockData.getHostById(hostId);
    return hostData?.name ?? 'Unknown Host';
  }

  bool get isHostVerified {
    final hostData = MockData.getHostById(hostId);
    return hostData?.isVerified ?? false;
  }

  List<String> get hostLanguages {
    final hostData = MockData.getHostById(hostId);
    return hostData?.languages ?? ['Unknown'];
  }

  String get hostResponseRate {
    final hostData = MockData.getHostById(hostId);
    return hostData?.responseRate ?? '0%';
  }

  DateTime get hostMemberSince {
    final hostData = MockData.getHostById(hostId);
    return hostData?.memberSince ?? DateTime(2020);
  }
}

class MapPin {
  final String id;
  final String experienceId;
  final double latitude;
  final double longitude;
  final String type; // 'primary' or 'secondary'

  const MapPin({
    required this.id,
    required this.experienceId,
    required this.latitude,
    required this.longitude,
    required this.type,
  });
}

class Review {
  final String id;
  final String experienceId;
  final String userName;
  final double rating;
  final String comment;
  final String timeAgo;

  const Review({
    required this.id,
    required this.experienceId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timeAgo,
  });
}

class Message {
  final String id;
  final String text;
  final String timestamp;
  final bool isSentByUser;

  const Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isSentByUser,
  });
}

/// Mock data provider
class MockData {
  /// Mock hosts data
  static final List<Host> hosts = [
    Host(
      id: 'QZAsBTTKSLhQjdajGOVsgsXEObi1',
      name: 'Carlos Mendoza',
      email: 'carlos.mendoza@email.com',
      isVerified: true,
      memberSince: DateTime(2019),
      languages: ['es', 'en'],
      responseRate: '98%',
      about:
          'Passionate coffee farmer and photography enthusiast from the Colombian mountains. I love sharing traditional farming methods and teaching sustainable coffee harvesting techniques.',
      hostedExperiences: 3,
      joinedExperiences: 7,
    ),
    Host(
      id: 'host_2',
      name: 'María Gutierrez',
      email: 'maria.gutierrez@email.com',
      isVerified: true,
      memberSince: DateTime(2020),
      languages: ['es'],
      responseRate: '95%',
      about:
          'Local fishing guide and English teacher from Honda, Colombia. I enjoy sharing our river culture and helping visitors practice their Spanish conversation skills.',
      hostedExperiences: 2,
      joinedExperiences: 5,
    ),
    Host(
      id: 'host_3',
      name: 'Ana Sofia Rodriguez',
      email: 'ana.sofia@email.com',
      isVerified: false,
      memberSince: DateTime(2024),
      languages: ['es', 'en', 'pt', 'fr'],
      responseRate: '100%',
      about:
          'Passionate about Colombian culture and digital design. Love connecting with travelers and sharing our beautiful traditions. I have been hosting experiences for over 3 years and enjoy meeting people from around the world.',
      hostedExperiences: 3,
      joinedExperiences: 7,
    ),
  ];

  static final List<Experience> experiences = [
    Experience(
      id: 'exp_1',
      title: 'Learn Coffee Harvesting & Teach Photography',
      summary:
          'Experience traditional coffee harvesting in the mountains while sharing your photography skills with local farmers',
      hostId: 'host_1',
      hostVerified: true,
      department: 'Tolima',
      location: {"latitude": 4.4389, "longitude": -75.2322},
      avgRating: 4.9,
      reviewsCount: 18,
      duration: 3,
      skillsToLearn: ['Coffee Harvesting', 'Traditional Farming Methods'],
      skillsToTeach: ['Photography Techniques', 'Digital Editing'],
      categories: ['Agriculture', 'Outdoor'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      priceCOP: 150000,
      groupSizeMax: 6,
      paymentOptions: ['cash', 'card'],
      isActive: true,
    ),
    Experience(
      id: 'exp_2',
      title: 'Fishing on Magdalena River & Practice English',
      summary:
          'Join local fishermen on the Magdalena River while practicing English conversation and learning traditional fishing methods',
      hostId: 'host_2',
      hostVerified: true,
      department: 'Tolima',
      location: {"latitude": 5.2084, "longitude": -74.7372},
      avgRating: 4.7,
      reviewsCount: 12,
      duration: 4,
      skillsToLearn: ['Traditional Fishing', 'River Navigation'],
      skillsToTeach: ['English Conversation', 'Cultural Exchange'],
      categories: ['Outdoor', 'Culture'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      priceCOP: 100000,
      groupSizeMax: 4,
      paymentOptions: ['cash'],
      isActive: true,
    ),
    Experience(
      id: 'exp_3',
      title: 'Colombian Cooking & Digital Design Workshop',
      summary:
          'Learn to cook traditional Colombian dishes while teaching modern digital design techniques',
      hostId: 'host_3',
      hostVerified: false,
      department: 'Bogotá D.C.',
      location: {"latitude": 4.7110, "longitude": -74.0721},
      avgRating: 4.8,
      reviewsCount: 24,
      duration: 5,
      skillsToLearn: ['Colombian Cuisine', 'Traditional Recipes'],
      skillsToTeach: ['UI/UX Design', 'Adobe Creative Suite'],
      categories: ['Culinary', 'Technology'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      priceCOP: 200000,
      groupSizeMax: 10,
      paymentOptions: ['card'],
      isActive: true,
    ),
    Experience(
      id: 'exp_4',
      title: 'Salsa Dancing & Language Exchange',
      summary:
          'Learn authentic Colombian salsa moves while practicing Spanish conversation with local dancers',
      hostId: 'host_3',
      hostVerified: false,
      department: 'Valle del Cauca',
      location: {"latitude": 3.4516, "longitude": -76.5320},
      avgRating: 4.6,
      reviewsCount: 31,
      duration: 2,
      skillsToLearn: ['Salsa Dancing', 'Colombian Rhythms'],
      skillsToTeach: ['Foreign Languages', 'Cultural Exchange'],
      categories: ['Arts', 'Culture'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      priceCOP: 80000,
      groupSizeMax: 12,
      paymentOptions: ['cash', 'card'],
      isActive: true,
    ),
    // Example experience with non-existent host (to test robustness)
    Experience(
      id: 'exp_5',
      title: 'Mountain Hiking & Survival Skills',
      summary:
          'Join an adventurous mountain hiking experience while learning essential survival skills',
      hostId: 'host_nonexistent', // This host doesn't exist in the hosts collection
      hostVerified: false,
      department: 'Santander',
      location: {"latitude": 7.1193, "longitude": -73.1227},
      avgRating: 4.5,
      reviewsCount: 8,
      duration: 2,
      skillsToLearn: ['Survival Skills', 'Mountain Navigation'],
      skillsToTeach: ['First Aid', 'Emergency Response'],
      categories: ['Adventure', 'Outdoor'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      priceCOP: 180000,
      groupSizeMax: 6,
      paymentOptions: ['cash'],
      isActive: true,
    ),
  ];

  static const List<MapPin> mapPins = [
    MapPin(
      id: 'pin_1',
      experienceId: 'exp_1',
      latitude: 4.4389,
      longitude: -75.2322,
      type: 'primary',
    ),
    MapPin(
      id: 'pin_2',
      experienceId: 'exp_2',
      latitude: 5.2084,
      longitude: -74.7372,
      type: 'secondary',
    ),
    MapPin(
      id: 'pin_3',
      experienceId: 'exp_3',
      latitude: 4.7110,
      longitude: -74.0721,
      type: 'primary',
    ),
    MapPin(
      id: 'pin_4',
      experienceId: 'exp_4',
      latitude: 3.4516,
      longitude: -76.5320,
      type: 'secondary',
    ),
    MapPin(
      id: 'pin_5',
      experienceId: 'exp_5',
      latitude: 7.1193,
      longitude: -73.1227,
      type: 'primary',
    ),
  ];

  static const List<Review> reviews = [
    Review(
      id: 'review_1',
      experienceId: 'exp_1',
      userName: 'Sarah Johnson',
      rating: 5.0,
      comment:
          'Amazing experience! Carlos taught me so much about coffee farming and I loved sharing photography tips with the local community.',
      timeAgo: '2 weeks ago',
    ),
    Review(
      id: 'review_2',
      experienceId: 'exp_1',
      userName: 'Mike Chen',
      rating: 4.8,
      comment:
          'Great cultural exchange. The coffee harvesting was harder than I expected but very rewarding!',
      timeAgo: '1 month ago',
    ),
    Review(
      id: 'review_3',
      experienceId: 'exp_2',
      userName: 'Emma Wilson',
      rating: 4.7,
      comment:
          'María is an excellent teacher! My Spanish improved so much during this fishing trip.',
      timeAgo: '3 weeks ago',
    ),
  ];

  /// Mock messages for messaging screen
  static const List<Message> messages = [
    Message(
      id: 'msg_1',
      text: 'Hi! Thanks for your interest in my cooking class. Do you have any dietary restrictions I should know about?',
      timestamp: '10:30 AM',
      isSentByUser: false,
    ),
    Message(
      id: 'msg_2',
      text: 'Hello! No dietary restrictions here. I\'m really excited to learn traditional Portuguese recipes!',
      timestamp: '10:45 AM',
      isSentByUser: true,
    ),
    Message(
      id: 'msg_3',
      text: 'Perfect! We\'ll be making pastéis de nata and bacalhau à brás. The class includes all ingredients and you\'ll take home recipes.',
      timestamp: '11:00 AM',
      isSentByUser: false,
    ),
    Message(
      id: 'msg_4',
      text: 'That sounds amazing! What should I bring?',
      timestamp: '11:15 AM',
      isSentByUser: true,
    ),
    Message(
      id: 'msg_5',
      text: 'Just bring an apron if you have one, and your appetite! Everything else is provided. See you tomorrow at 2 PM!',
      timestamp: '11:20 AM',
      isSentByUser: false,
    ),
  ];

  /// Filter experiences based on search query and filters
  static List<Experience> filterExperiences({
    String? searchQuery,
    List<String>? categories,
    List<String>? regions,
    double? maxPrice,
    List<String>? languages,
    bool? sustainabilityOnly,
  }) {
    List<Experience> filtered = List.from(experiences);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where((exp) =>
              exp.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              exp.summary
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              exp.department.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (categories != null && categories.isNotEmpty) {
      filtered =
          filtered.where((exp) => exp.categories.any(categories.contains)).toList();
    }

    if (regions != null && regions.isNotEmpty) {
      filtered = filtered
          .where(
              (exp) => regions.any((region) => exp.department.contains(region)))
          .toList();
    }

    // Sort by rating by default
    filtered.sort((a, b) => b.avgRating.compareTo(a.avgRating));

    return filtered;
  }

  /// Get experience by ID
  static Experience? getExperienceById(String id) {
    try {
      return experiences.firstWhere((exp) => exp.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get host by ID
  static Host? getHostById(String id) {
    try {
      return hosts.firstWhere((host) => host.id == id);
    } catch (e) {
      // Host not found in collection
      // In a real app, this would log the error for debugging
      // print('Host with id $id not found in hosts collection');
      return null;
    }
  }

  /// Check if host exists in the collection
  static bool hostExists(String hostId) {
    return hosts.any((host) => host.id == hostId);
  }

  /// Get reviews for experience
  static List<Review> getReviewsForExperience(String experienceId) {
    return reviews
        .where((review) => review.experienceId == experienceId)
        .toList();
  }

  /// Get messages for host conversation
  static List<Message> getMessagesForHost(String hostId) {
    // For now, return the same messages for all hosts
    // In a real app, this would be filtered by hostId
    return List.from(messages);
  }

  /// Get current user (for profile screen)
  static Host get currentUser => hosts[2]; // Ana Sofia Rodriguez

  /// Available categories for filtering
  static const List<String> categories = [
    'Agriculture',
    'Arts',
    'Culinary',
    'Education',
    'Outdoor',
    'Technology',
    'Wellness',
  ];

  /// Available regions for filtering
  static const List<String> regions = [
    'Bogotá D.C.',
    'Valle del Cauca',
    'Antioquia',
    'Tolima',
  ];

  /// Available languages for filtering
  static const List<String> availableLanguages = [
    'Spanish',
    'English',
    'Portuguese',
    'French',
    'German',
    'Italian',
  ];
}
