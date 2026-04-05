import 'package:flutter/material.dart';

/// Holds the custom color palette for the app.
class AppColors {
  // Primary
  static const Color primaryRed = Color(0xFFE60000);
  static const Color primaryPink = Color(0xFFFFB6B6);
  static const Color primaryPinkLight = Color(0xFFFFDADA);
  static const Color primaryPinkLighter = Color(0xFFFFECEC);

  // Light Theme
  static const Color lightBg = Color.fromARGB(
    255,
    255,
    238,
    238,
  ); // Your light theme bg
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Dark Theme
  static const Color darkBg = Color.fromARGB(255, 48, 48, 48);
  static const Color darkCardBg = Color.fromARGB(255, 68, 68, 68);
  static const Color darkSecondary = Color.fromARGB(255, 149, 149, 149);

  // Other
  static const Color googleBlue = Color(0xFF4285F4);
}
