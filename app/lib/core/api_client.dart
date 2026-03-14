import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    // Interceptor: auto-inject Firebase ID token in every request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}
        handler.next(options);
      },
      onError: (DioException error, handler) {
        handler.next(error);
      },
    ));
  }

  // Auth
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final res = await _dio.post('/auth/google', data: {'idToken': idToken});
    return res.data;
  }

  // Expenses
  Future<List<dynamic>> getExpenses() async {
    final res = await _dio.get('/expenses');
    return res.data;
  }

  Future<Map<String, dynamic>> getExpenseSummary() async {
    final res = await _dio.get('/expenses/summary');
    return res.data;
  }

  Future<Map<String, dynamic>> addExpense(Map<String, dynamic> data) async {
    final res = await _dio.post('/expenses', data: data);
    return res.data;
  }

  Future<void> deleteExpense(String id) async {
    await _dio.delete('/expenses/$id');
  }

  // Workouts
  Future<List<dynamic>> getWorkouts() async {
    final res = await _dio.get('/workouts');
    return res.data;
  }

  Future<Map<String, dynamic>> getWorkoutSummary() async {
    final res = await _dio.get('/workouts/summary');
    return res.data;
  }

  Future<Map<String, dynamic>> addWorkout(Map<String, dynamic> data) async {
    final res = await _dio.post('/workouts', data: data);
    return res.data;
  }

  Future<void> deleteWorkout(String id) async {
    await _dio.delete('/workouts/$id');
  }

  // Mood
  Future<Map<String, dynamic>> logMood(String mood, {String note = ''}) async {
    final res = await _dio.post('/mood', data: {'mood': mood, 'note': note});
    return res.data;
  }

  Future<List<dynamic>> getMoodHistory() async {
    final res = await _dio.get('/mood/history');
    return res.data;
  }

  Future<List<dynamic>> getMoodStats() async {
    final res = await _dio.get('/mood/stats');
    return res.data;
  }
}
