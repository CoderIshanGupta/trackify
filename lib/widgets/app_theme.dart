import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Central place where I configure the app’s light and dark themes.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      textTheme: AppTypography.textTheme,
      // TODO: customize colors, components, etc.
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: AppTypography.textTheme,
      // TODO: customize dark theme colors and components.
    );
  }
}