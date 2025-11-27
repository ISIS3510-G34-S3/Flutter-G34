import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'firebase_options.dart';
import 'services/currency_service.dart';
import 'services/profile_service.dart';
import 'services/experience_service.dart';
import 'services/booking_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize currency service
  final currencyService = CurrencyService();
  await currencyService.initialize();

  // Initialize and start connectivity monitoring for offline-first services
  final profileService = ProfileService();
  profileService.startConnectivityMonitoring();

  final experienceService = ExperienceService();
  experienceService.startConnectivityMonitoring();

  final bookingService = BookingService();
  bookingService.startConnectivityMonitoring();

  // Configure system UI overlay style
  AppTheme.configureSystemUI();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: currencyService),
      ],
      child: const TravelConnectApp(),
    ),
  );
}
