import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TravelConnect Typography using Inter font family
class AppTypography {
  AppTypography._();

  // Base text style using Inter
  static TextStyle get _baseTextStyle => GoogleFonts.inter();

  // Title styles (used across all screens)
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.25,
        letterSpacing: -0.25,
      );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // Subtitle styles
  static TextStyle get subtitleLarge => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get subtitleMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get subtitleSmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // Body text styles
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Button styles
  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.1,
      );

  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.1,
      );

  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.5,
      );

  // Label styles
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.5,
      );

  // Caption styles
  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.3,
        letterSpacing: 0.4,
      );

  static TextStyle get overline => _baseTextStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.6,
        letterSpacing: 1.5,
      );

  // Display styles
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.125,
        letterSpacing: -1.0,
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.15,
        letterSpacing: -0.75,
      );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
      );
}

/// Text theme for Material 3
TextTheme get appTextTheme => TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.titleLarge,
      headlineMedium: AppTypography.titleMedium,
      headlineSmall: AppTypography.titleSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    );
