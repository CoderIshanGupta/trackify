import 'package:flutter/foundation.dart';

import '../models/task_model.dart';

/// Provider for tasks / to‑dos.
class TaskProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];
  bool _isLoading = false;
  Object? _error;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: load tasks from backend/local storage.
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(TaskModel task) async {
    // TODO: persist task if required.
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    // TODO: toggle completion, update in list and sync to backend.
    notifyListeners();
  }

  Future<void> deleteTask(TaskModel task) async {
    // TODO: delete from backend if needed.
    _tasks.remove(task);
    notifyListeners();
  }
}