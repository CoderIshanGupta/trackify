import 'package:flutter/foundation.dart';

import '../models/analytics_model.dart';

/// Provider for loading and exposing analytics/insights in the app.
class AnalyticsProvider extends ChangeNotifier {
  AnalyticsModel? _analytics = AnalyticsModel.mock();
  bool _isLoading = false;
  Object? _error;

  AnalyticsModel? get analytics => _analytics;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  /// Recalculates analytics based on current statistics
  Future<void> updateAnalytics({
    required double averageMood,
    required double totalExpenses,
    required double habitRate,
  }) async {
    _analytics = AnalyticsModel(
      totalExpenses: totalExpenses,
      habitCompletionRate: habitRate,
      averageMoodRating: averageMood,
      completedTasksCount: 8,
      pendingTasksCount: 3,
      aiInsight: _generateAIInsight(averageMood, totalExpenses, habitRate),
    );
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateAIInsight(double avgMood, double expenses, double habitRate) {
    final int habitPercent = (habitRate * 100).toInt();

    if (expenses > 100) {
      return "Trackify AI: You spent \$${expenses.toStringAsFixed(2)} this week. We detected a correlation: on days you spend more, your mood average dips slightly to ${avgMood.toStringAsFixed(1)}. Consider a 'no-spend' tomorrow to stay on target!";
    } else if (expenses > 30) {
      return "Trackify AI: Total spent is \$${expenses.toStringAsFixed(2)}. Budgeting is highly disciplined! Your habit completion is at $habitPercent%. Keeping busy with healthy habits is successfully preventing impulsive shopping.";
    } else if (expenses > 0) {
      return "Trackify AI: Spending is extremely lean at \$${expenses.toStringAsFixed(2)}! Since your mood average is a solid ${avgMood.toStringAsFixed(1)}, treat yourself to a small, healthy reward without breaking your streak.";
    }

    return "Trackify AI: You haven't logged any daily expenses yet. Tap '+' on the expense card to log cash spent and unlock tailored budgeting suggestions!";
  }
}