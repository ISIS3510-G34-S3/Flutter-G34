import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import 'router.dart';

/// Main app widget
class TravelConnectApp extends StatelessWidget {
  const TravelConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure system UI
    AppTheme.configureSystemUI();

    return MaterialApp.router(
      title: 'TravelConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,

      // Builder to set system UI overlay style per route
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1C3A13), // AppColors.forestGreen
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFFFAFAFA), // AppColors.background
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
