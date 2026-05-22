import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All the base text styles I want to use in the app in one place.
class AppTypography {
  static TextStyle get heading1 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get heading2 => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 14,
  );

  static TextTheme textTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      headlineLarge: heading1,
      headlineMedium: heading2,
      bodyMedium: body,
    );
  }
}