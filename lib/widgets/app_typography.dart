import 'package:flutter/material.dart';

/// All the base text styles I want to use in the app in one place.
class AppTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
  );

  static const TextTheme textTheme = TextTheme(
    headlineLarge: heading1,
    headlineMedium: heading2,
    bodyMedium: body,
  );
}