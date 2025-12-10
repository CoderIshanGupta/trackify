import 'package:flutter/material.dart';

/// Single row widget for showing one mood entry.
///
/// This will show rating, date, and maybe a short note.
class MoodListItem extends StatelessWidget {
  const MoodListItem({
    super.key,
    // Later I’ll add fields:
    // required this.date,
    // required this.rating,
    // this.note,
  });

  // final DateTime date;
  // final int rating;
  // final String? note;

  @override
  Widget build(BuildContext context) {
    // I’ll design how a mood entry should look in a list.
    return const ListTile(
      title: Text('TODO: implement MoodListItem'),
      subtitle: Text('Rating, date, and note.'),
    );
  }
}