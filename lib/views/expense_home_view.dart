import 'package:flutter/material.dart';

/// Main screen for expenses.
///
/// I’ll show the list of expenses, filters, totals, etc. here.
class ExpenseHomeView extends StatelessWidget {
  const ExpenseHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Later I’ll use ExpenseProvider + ExpenseListItem here.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: const Center(
        child: Text(
          'Expense Home\nTODO: show expense list and summary here.',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open add expense flow.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}