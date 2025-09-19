import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/explore/discover_screen.dart';
import '../features/experience/detail_screen.dart';
import '../features/experience/booking_screen.dart';
import '../features/map/map_screen.dart';
import '../features/create/create_experience_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/profie_verification_screen.dart';
import '../features/messaging/messaging_screen.dart';
import '../widgets/main_scaffold.dart';

/// Main router configuration for the app
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Login route (standalone)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Discover (Home) route
        GoRoute(
          path: '/discover',
          name: 'discover',
          builder: (context, state) => const DiscoverScreen(),
        ),

        // Map route
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),

        // Create experience route
        GoRoute(
          path: '/create',
          name: 'create',
          builder: (context, state) => const CreateExperienceScreen(),
        ),

        // Profile route
        GoRoute(
          path: '/profile/:id',
          name: 'profile',
          builder: (context, state) {
            final profileId = state.pathParameters['id'] ?? 'current';
            return ProfileScreen(profileId: profileId);
          },
        ),
      ],
    ),

    // Experience detail route (standalone)
    GoRoute(
      path: '/experience/:id',
      name: 'experience',
      builder: (context, state) {
        final experienceId = state.pathParameters['id']!;
        return ExperienceDetailScreen(experienceId: experienceId);
      },
    ),

    // Booking route (standalone)
    GoRoute(
      path: '/booking/:experienceId',
      name: 'booking',
      builder: (context, state) {
        final experienceId = state.pathParameters['experienceId']!;
        return BookingScreen(experienceId: experienceId);
      },
    ),

    // Profile verification route (standalone)
    GoRoute(
      path: '/profile-verification',
      name: 'profile-verification',
      builder: (context, state) => const ProfileVerificationScreen(),
    ),

    // Messaging route (standalone)
    GoRoute(
      path: '/messaging/:hostId',
      name: 'messaging',
      builder: (context, state) {
        final hostId = state.pathParameters['hostId']!;
        return MessagingScreen(hostId: hostId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you\'re looking for doesn\'t exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/discover'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
