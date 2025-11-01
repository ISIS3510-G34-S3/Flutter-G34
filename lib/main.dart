import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'firebase_options.dart';
import 'services/currency_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize currency service
  final currencyService = CurrencyService();
  await currencyService.initialize();

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
