import 'package:flutter/material.dart';

import 'views/analytics_home_view.dart';
import 'widgets/app_theme.dart';

void main() {
  runApp(const TrackifyApp());
}

/// App entry point widget.
class TrackifyApp extends StatelessWidget {
  const TrackifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackify',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AnalyticsHomeView(),
    );
  }
}