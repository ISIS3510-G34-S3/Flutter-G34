/// Mock data models and providers for TravelConnect app
class Host {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final String memberSince;
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
  final String description;
  final Host host;
  final String location;
  final double rating;
  final int reviewCount;
  final String duration;
  final List<String> skillsToLearn;
  final List<String> skillsToTeach;
  final String category;
  final String timeAgo;
  final double latitude;
  final double longitude;

  const Experience({
    required this.id,
    required this.title,
    required this.description,
    required this.host,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.skillsToLearn,
    required this.skillsToTeach,
    required this.category,
    required this.timeAgo,
    required this.latitude,
    required this.longitude,
  });
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

/// Mock data provider
class MockData {
  static const List<Host> hosts = [
    Host(
      id: 'host_1',
      name: 'Carlos Mendoza',
      email: 'carlos.mendoza@email.com',
      isVerified: true,
      memberSince: '2019',
      languages: ['Spanish (Native)', 'English (Fluent)', 'Portuguese (Basic)'],
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
      memberSince: '2020',
      languages: ['Spanish (Native)', 'English (Intermediate)'],
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
      memberSince: '2024',
      languages: [
        'Spanish (Native)',
        'English (Fluent)',
        'Portuguese (Basic)',
        'French (Learning)'
      ],
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
      description:
          'Experience traditional coffee harvesting in the mountains while sharing your photography skills with local farmers',
      host: hosts[0],
      location: 'Tolima, Colombia',
      rating: 4.9,
      reviewCount: 18,
      duration: '3 hours',
      skillsToLearn: ['Coffee Harvesting', 'Traditional Farming Methods'],
      skillsToTeach: ['Photography Techniques', 'Digital Editing'],
      category: 'Agriculture',
      timeAgo: '2 days',
      latitude: 4.4389,
      longitude: -75.2322,
    ),
    Experience(
      id: 'exp_2',
      title: 'Fishing on Magdalena River & Practice English',
      description:
          'Join local fishermen on the Magdalena River while practicing English conversation and learning traditional fishing methods',
      host: hosts[1],
      location: 'Honda, Colombia',
      rating: 4.7,
      reviewCount: 12,
      duration: '4 hours',
      skillsToLearn: ['Traditional Fishing', 'River Navigation'],
      skillsToTeach: ['English Conversation', 'Cultural Exchange'],
      category: 'Outdoor',
      timeAgo: '1 week',
      latitude: 5.2084,
      longitude: -74.7372,
    ),
    Experience(
      id: 'exp_3',
      title: 'Colombian Cooking & Digital Design Workshop',
      description:
          'Learn to cook traditional Colombian dishes while teaching modern digital design techniques',
      host: hosts[2],
      location: 'Bogotá, Colombia',
      rating: 4.8,
      reviewCount: 24,
      duration: '5 hours',
      skillsToLearn: ['Colombian Cuisine', 'Traditional Recipes'],
      skillsToTeach: ['UI/UX Design', 'Adobe Creative Suite'],
      category: 'Culinary',
      timeAgo: '3 days',
      latitude: 4.7110,
      longitude: -74.0721,
    ),
    Experience(
      id: 'exp_4',
      title: 'Salsa Dancing & Language Exchange',
      description:
          'Learn authentic Colombian salsa moves while practicing Spanish conversation with local dancers',
      host: hosts[2],
      location: 'Cali, Colombia',
      rating: 4.6,
      reviewCount: 31,
      duration: '2 hours',
      skillsToLearn: ['Salsa Dancing', 'Colombian Rhythms'],
      skillsToTeach: ['Foreign Languages', 'Cultural Exchange'],
      category: 'Arts',
      timeAgo: '5 days',
      latitude: 3.4516,
      longitude: -76.5320,
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
              exp.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              exp.location.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (categories != null && categories.isNotEmpty) {
      filtered =
          filtered.where((exp) => categories.contains(exp.category)).toList();
    }

    if (regions != null && regions.isNotEmpty) {
      filtered = filtered
          .where(
              (exp) => regions.any((region) => exp.location.contains(region)))
          .toList();
    }

    // Sort by rating by default
    filtered.sort((a, b) => b.rating.compareTo(a.rating));

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
      return null;
    }
  }

  /// Get reviews for experience
  static List<Review> getReviewsForExperience(String experienceId) {
    return reviews
        .where((review) => review.experienceId == experienceId)
        .toList();
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
    'Bogotá',
    'Medellín',
    'Cali',
    'Cartagena',
    'Tolima',
    'Honda',
    'Antioquia',
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
