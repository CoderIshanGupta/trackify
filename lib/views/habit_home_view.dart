import 'package:flutter/material.dart';

/// Main screen for habit tracking.
///
/// I’ll show all habits, allow marking them as done, and display streaks.
class HabitHomeView extends StatelessWidget {
  const HabitHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Later I’ll use HabitProvider + HabitListItem here.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      body: const Center(
        child: Text(
          'Habit Home\nTODO: show list of habits and progress here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}