import 'package:flutter/material.dart';
import 'app/app.dart';
import 'theme/theme.dart';

void main() {
  // Configure system UI overlay style
  AppTheme.configureSystemUI();
  runApp(const TravelConnectApp());
}
