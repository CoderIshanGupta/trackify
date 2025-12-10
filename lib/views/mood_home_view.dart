import 'package:flutter/material.dart';

/// Main screen for mood tracking.
///
/// I’ll let the user log mood entries and view their history/trends here.
class MoodHomeView extends StatelessWidget {
  const MoodHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Later I’ll use MoodProvider + MoodListItem here.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood'),
      ),
      body: const Center(
        child: Text(
          'Mood Home\nTODO: show mood logs and trends here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}