import 'package:flutter/material.dart';

/// Single row widget for showing one habit.
///
/// I’ll show the habit name, its status for today, and maybe streak info.
class HabitListItem extends StatelessWidget {
  const HabitListItem({
    super.key,
    // Later I’ll add fields:
    // required this.title,
    // required this.isCompletedToday,
    // this.onToggle,
  });

  // final String title;
  // final bool isCompletedToday;
  // final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    // I’ll create the final habit row design here.
    return const ListTile(
      title: Text('TODO: implement HabitListItem'),
      subtitle: Text('Streak, completion status, etc.'),
    );
  }
}