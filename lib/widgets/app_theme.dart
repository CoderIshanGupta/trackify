import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_typography.dart';

/// Central place where I configure the app’s light and dark themes.
class AppTheme {
  // FamPay-inspired dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color accentNeon = Color(0xFFFFB800); // Vibrant Yellow
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accentNeon,
      colorScheme: const ColorScheme.dark(
        primary: accentNeon,
        secondary: accentNeon,
        surface: cardDark,
      ),
      textTheme: AppTypography.textTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentNeon,
          foregroundColor: backgroundDark,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData get lightTheme {
    return darkTheme; // For this specific FamPay style, default to dark theme.
  }
}