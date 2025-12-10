import 'package:flutter/material.dart';

/// Small reusable card to show a single analytics metric or summary.
///
/// I’ll use this in the analytics screen for things like:
/// - total spent this month
/// - number of habits completed
/// - average mood, etc.
class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    // Later I’ll add required fields like:
    // required this.title,
    // required this.value,
    // this.subtitle,
    // this.icon,
  });

  // final String title;
  // final String value;
  // final String? subtitle;
  // final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // I’ll replace this with the final design for the card.
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('TODO: implement AnalyticsCard UI'),
      ),
    );
  }
}