import 'package:flutter/material.dart';

/// Single row widget for showing one task.
///
/// I’ll show title, completion status, and maybe due date/priority here.
class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    // Later I’ll add fields:
    // required this.title,
    // required this.isCompleted,
    // this.onToggleCompleted,
  });

  // final String title;
  // final bool isCompleted;
  // final VoidCallback? onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    // I’ll design the task row UI here.
    return const ListTile(
      title: Text('TODO: implement TaskListItem'),
      subtitle: Text('Completion status, due date, etc.'),
    );
  }
}