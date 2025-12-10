import 'package:flutter/material.dart';

/// Main analytics/insights screen.
///
/// Here I’ll combine data from expenses, habits, mood, and tasks
/// and show summary cards, charts, and AI-generated insights.
class AnalyticsHomeView extends StatelessWidget {
  const AnalyticsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // I’ll replace this with a proper dashboard layout later.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: const Center(
        child: Text(
          'Analytics Home\nTODO: build analytics dashboard here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}