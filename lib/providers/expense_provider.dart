import 'package:flutter/foundation.dart';

import '../models/expense_model.dart';

/// Provider for managing expenses.
class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseModel> _expenses = [
    ExpenseModel(
      id: 'e1',
      amount: 4.50,
      category: 'Food',
      note: 'Morning hazelnut latte ☕',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    ExpenseModel(
      id: 'e2',
      amount: 65.20,
      category: 'Shopping',
      note: 'Weekly organic groceries 🥦',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    ExpenseModel(
      id: 'e3',
      amount: 15.00,
      category: 'Entertainment',
      note: 'Sci-fi movie ticket 🍿',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
  ];

  bool _isLoading = false;
  Object? _error;

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    // Add new entries to the top
    _expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    _expenses.removeWhere((item) => item.id == expense.id);
    notifyListeners();
  }

  /// Calculates exact total amount spent
  double get totalSpent {
    return _expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }
}