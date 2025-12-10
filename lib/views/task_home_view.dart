import 'package:flutter/material.dart';

/// Main screen for tasks / to‑dos.
///
/// I’ll show upcoming tasks, completion status, and actions here.
class TaskHomeView extends StatelessWidget {
  const TaskHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Later I’ll use TaskProvider + TaskListItem here.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: const Center(
        child: Text(
          'Task Home\nTODO: show task list and details here.',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open add task flow.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}