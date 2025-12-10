import 'package:flutter/foundation.dart';

import '../models/analytics_model.dart';

/// Provider for loading and exposing analytics/insights in the app.
class AnalyticsProvider extends ChangeNotifier {
  AnalyticsModel? _analytics;
  bool _isLoading = false;
  Object? _error;

  AnalyticsModel? get analytics => _analytics;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  /// Later I’ll hook this up to the other providers/services
  /// and compute AnalyticsModel from real data.
  Future<void> loadAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: implement analytics loading and calculations.
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}