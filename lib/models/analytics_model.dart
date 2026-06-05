/// Model for all the aggregated analytics/insights I want to show in the app.
class AnalyticsModel {
  final double totalExpenses;
  final double habitCompletionRate; // 0.0 to 1.0
  final double averageMoodRating; // 1.0 to 5.0
  final int completedTasksCount;
  final int pendingTasksCount;
  final String aiInsight;

  AnalyticsModel({
    required this.totalExpenses,
    required this.habitCompletionRate,
    required this.averageMoodRating,
    required this.completedTasksCount,
    required this.pendingTasksCount,
    required this.aiInsight,
  });

  /// Factory constructor to create a mock starting model
  factory AnalyticsModel.mock() {
    return AnalyticsModel(
      totalExpenses: 2450.80,
      habitCompletionRate: 0.75,
      averageMoodRating: 4.2,
      completedTasksCount: 8,
      pendingTasksCount: 3,
      aiInsight: "Smart Insight: Your highest moods coincide with days you spent \$0! You tend to feel more energetic after running. Keep tracking habits to discover new trends.",
    );
  }
}