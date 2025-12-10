import 'package:flutter/foundation.dart';

import '../models/expense_model.dart';

/// Provider for managing expenses (CRUD, loading, etc.).
class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseModel> _expenses = [];
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
      // TODO: fetch expenses from Firebase/local storage.
      // _expenses
      //   ..clear()
      //   ..addAll(fetchedExpenses);
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    // TODO: save to backend first (Firestore/Realtime DB) if needed.
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> updateExpense(ExpenseModel updated) async {
    // TODO: implement update logic and persistence.
    notifyListeners();
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    // TODO: delete from backend if required.
    _expenses.remove(expense);
    notifyListeners();
  }
}