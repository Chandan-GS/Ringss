import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/core/theme/app_colors.dart';

/// Contains the theme data for the app, using Pixelify Sans.
class AppTheme {
  static ThemeData get lightTheme {
    // Start with a base light theme
    final baseTheme = ThemeData.light();

    // Create a Pixelify Sans text theme
    final pixelTextTheme = GoogleFonts.pixelifySansTextTheme(
      baseTheme.textTheme,
    );

    // Your original light theme colors
    return baseTheme.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white, // Your original color
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.white, // Your original color
        secondary: AppColors.primaryPink, // Your original color
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        background: AppColors.lightBg,
        surface: AppColors.white,
        onBackground: AppColors.black,
        onSurface: AppColors.black,
      ),
      // Apply the Pixelify text theme AND your custom colors
      textTheme: pixelTextTheme.copyWith(
        titleMedium: pixelTextTheme.titleMedium?.copyWith(
          color: AppColors.black,
        ),
        bodyMedium: pixelTextTheme.bodyMedium?.copyWith(color: AppColors.black),
        bodyLarge: pixelTextTheme.bodyLarge?.copyWith(
          color: Colors.transparent,
        ),
        titleSmall: pixelTextTheme.titleSmall?.copyWith(color: AppColors.black),
        titleLarge: pixelTextTheme.titleLarge?.copyWith(
          color: AppColors.primaryRed,
        ),
        bodySmall: pixelTextTheme.bodySmall?.copyWith(color: AppColors.white),
      ),
      hintColor: const Color.fromARGB(255, 177, 177, 177),
      primaryIconTheme: const IconThemeData(color: AppColors.white),
      cardColor: AppColors.primaryPink, // Used for icon button border
      cardTheme: const CardThemeData(
        color: Color.fromARGB(255, 248, 248, 248),
        shadowColor: Color.fromARGB(255, 222, 222, 222),
        surfaceTintColor: AppColors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Start with a base dark theme
    final baseTheme = ThemeData.dark();

    // Create a Pixelify Sans text theme
    final pixelTextTheme = GoogleFonts.pixelifySansTextTheme(
      baseTheme.textTheme,
    );

    // Your original dark theme colors
    return baseTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 130, 130, 130),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkCardBg, // Your original color
        secondary: AppColors.darkSecondary, // Your original color
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        background: AppColors.darkBg,
        surface: AppColors.darkCardBg,
        onBackground: AppColors.white,
        onSurface: AppColors.white,
      ),
      // Apply the Pixelify text theme AND your custom colors
      textTheme: pixelTextTheme.copyWith(
        titleMedium: pixelTextTheme.titleMedium?.copyWith(
          color: AppColors.white,
        ),
        bodyMedium: pixelTextTheme.bodyMedium?.copyWith(color: AppColors.white),
        bodyLarge: pixelTextTheme.bodyLarge?.copyWith(
          color: Colors.transparent,
        ),
        titleSmall: pixelTextTheme.titleSmall?.copyWith(color: AppColors.white),
        titleLarge: pixelTextTheme.titleLarge?.copyWith(
          color: const Color.fromARGB(255, 255, 98, 98),
        ),
        bodySmall: pixelTextTheme.bodySmall?.copyWith(color: AppColors.black),
      ),
      hintColor: const Color.fromARGB(255, 99, 99, 99),
      primaryIconTheme: const IconThemeData(color: AppColors.darkSecondary),
      cardColor: const Color.fromARGB(
        255,
        79,
        79,
        79,
      ), // Used for icon button border
      cardTheme: const CardThemeData(
        color: Color.fromARGB(255, 183, 183, 183),
        shadowColor: Color.fromARGB(255, 149, 149, 149),
        surfaceTintColor: Color.fromARGB(255, 220, 220, 220),
      ),
    );
  }
}
