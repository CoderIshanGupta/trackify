import 'package:flutter/foundation.dart';

import '../models/habit_model.dart';

/// Provider for habits (tracking, streaks, etc.).
class HabitProvider extends ChangeNotifier {
  final List<HabitModel> _habits = [];
  bool _isLoading = false;
  Object? _error;

  List<HabitModel> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: load habits from backend/local storage.
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    // TODO: persist habit if required.
    _habits.add(habit);
    notifyListeners();
  }

  Future<void> updateHabit(HabitModel updated) async {
    // TODO: find and update habit, then sync changes.
    notifyListeners();
  }

  Future<void> deleteHabit(HabitModel habit) async {
    // TODO: delete from backend if needed.
    _habits.remove(habit);
    notifyListeners();
  }
}