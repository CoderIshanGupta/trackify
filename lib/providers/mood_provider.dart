import 'package:flutter/foundation.dart';

import '../models/mood_model.dart';

/// Provider for mood logs/history.
class MoodProvider extends ChangeNotifier {
  final List<MoodModel> _moods = [
    MoodModel(
      id: '1',
      rating: 5,
      label: 'Rad',
      note: 'Finished a major app update! Feeling super accomplished.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      emoji: '😆',
    ),
    MoodModel(
      id: '2',
      rating: 4,
      label: 'Good',
      note: 'Went for an evening run. Health is wealth!',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      emoji: '🙂',
    ),
    MoodModel(
      id: '3',
      rating: 3,
      label: 'Meh',
      note: 'A bit of a slow day, sluggish afternoon.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      emoji: '😐',
    ),
    MoodModel(
      id: '4',
      rating: 2,
      label: 'Bad',
      note: 'Felt tired, didn\'t sleep well last night.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      emoji: '😔',
    ),
    MoodModel(
      id: '5',
      rating: 5,
      label: 'Rad',
      note: 'Hung out with friends, great food and vibes!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      emoji: '😆',
    ),
  ];

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
      // In-memory loading, just mock some latency
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMood(MoodModel mood) async {
    // Add to top of the list so it is shown first in logs
    _moods.insert(0, mood);
    notifyListeners();
  }

  /// Calculates average mood rating
  double get averageMood {
    if (_moods.isEmpty) return 0.0;
    final total = _moods.fold<int>(0, (sum, item) => sum + item.rating);
    return double.parse((total / _moods.length).toStringAsFixed(1));
  }
}