import 'package:flutter/foundation.dart';

import '../models/mood_model.dart';

/// Provider for mood logs/history.
class MoodProvider extends ChangeNotifier {
  final List<MoodModel> _moods = [];
  bool _isLoading = false;
  Object? _error;

  List<MoodModel> get moods => List.unmodifiable(_moods);
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadMoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: load moods from backend/local storage.
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMood(MoodModel mood) async {
    // TODO: persist mood entry if needed.
    _moods.add(mood);
    notifyListeners();
  }
}