import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defines pre-styled text styles using Pixelify Sans.
/// NOTE: You should prefer using Theme.of(context).textTheme...
/// This is just for special cases.
class AppTypography {
  static final TextStyle screenTitle = GoogleFonts.pixelifySans(
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonText = GoogleFonts.pixelifySans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle body = GoogleFonts.pixelifySans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
