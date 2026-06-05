import '../providers/analytics_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/mood_provider.dart';

class AppState {
  static final MoodProvider moodProvider = MoodProvider();
  static final ExpenseProvider expenseProvider = ExpenseProvider();
  static final AnalyticsProvider analyticsProvider = AnalyticsProvider();

  /// Recalculates analytics based on actual logged expenses, moods, and habits
  static void syncAnalytics({double habitRate = 0.75}) {
    analyticsProvider.updateAnalytics(
      averageMood: moodProvider.averageMood,
      totalExpenses: expenseProvider.totalSpent,
      habitRate: habitRate,
    );
  }
}
