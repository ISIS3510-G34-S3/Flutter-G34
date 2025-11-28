import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_connect/services/experience_service.dart';

import 'syncing_toast.dart';

/// Main scaffold with bottom navigation that persists across main tabs
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    return ValueListenableBuilder<bool>(
      valueListenable: ExperienceService.syncingNotifier,
      builder: (context, isSyncing, _) {
        return Stack(
          children: [
            Scaffold(
              body: child,
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _calculateSelectedIndex(currentLocation),
                onTap: (index) => _onTabTapped(context, index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined),
                    activeIcon: Icon(Icons.map),
                    label: 'Map',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    activeIcon: Icon(Icons.calendar_today),
                    label: 'Bookings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore),
                    label: 'Experiences',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    activeIcon: Icon(Icons.chat_bubble),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
            if (isSyncing) const SyncingToast(),
          ],
        );
      },
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/discover')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/my-bookings')) return 2;
    if (location.startsWith('/my-experiences') ||
        location.startsWith('/create')) return 3;
    if (location.startsWith('/messages')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0; // Default to home
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/discover');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/my-bookings');
        break;
      case 3:
        context.go('/my-experiences');
        break;
      case 4:
        context.go('/messages');
        break;
      case 5:
        context.go('/profile/current');
        break;
    }
  }
}
