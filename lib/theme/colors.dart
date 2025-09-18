import 'package:flutter/material.dart';

/// TravelConnect Color Palette
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color peach = Color(0xFFFEC0AA);
  static const Color lava = Color(0xFFEC4E20);
  static const Color oliveGold = Color(0xFF84732B);
  static const Color earthBrown = Color(0xFF574F2A);
  static const Color forestGreen = Color(0xFF1C3A13);

  // Neutrals
  static const Color background = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF2A2A2A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color white = Color(0xFFFFFFFF);
  static const Color divider = Color(0x66574F2A); // earthBrown @ 40% opacity
  static const Color disabled = Color(0x4D574F2A); // earthBrown @ 30% opacity

  // System colors derived from brand palette
  static const Color primary = forestGreen;
  static const Color primaryVariant = earthBrown;
  static const Color secondary = lava;
  static const Color secondaryVariant = oliveGold;
  static const Color surface = white;
  static const Color error = Color(0xFFB3261E);
  static const Color onPrimary = white;
  static const Color onSecondary = white;
  static const Color onSurface = textPrimary;
  static const Color onBackground = textPrimary;
  static const Color onError = white;

  // Semantic colors
  static const Color success = forestGreen;
  static const Color warning = oliveGold;
  static const Color info = Color(0xFF2196F3);

  // Gradient colors
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestGreen, earthBrown],
  );

  static const LinearGradient overlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x40000000),
      Color(0x80000000),
    ],
  );
}
