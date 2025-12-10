import 'package:flutter/material.dart';

/// Single row widget for showing one expense in a list.
///
/// I’ll pass an ExpenseModel (or equivalent data) into this later.
class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    // Later I’ll add the actual fields:
    // required this.title,
    // required this.amount,
    // required this.date,
    // this.onTap,
  });

  // final String title;
  // final double amount;
  // final DateTime date;
  // final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // I’ll design the final look for the expense row here.
    return const ListTile(
      title: Text('TODO: implement ExpenseListItem'),
      subtitle: Text('Amount, category, date, etc.'),
    );
  }
}