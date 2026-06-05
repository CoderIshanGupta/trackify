import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'views/analytics_home_view.dart';
import 'views/login_view.dart';
import 'widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure Firebase is initialized before running the app.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed (Check google-services.json): $e');
  }
  runApp(const TrackifyApp());
}

/// App entry point widget.
class TrackifyApp extends StatelessWidget {
  const TrackifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackify',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force FamPay dark theme
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper to handle auth state changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentNeon,
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const AnalyticsHomeView();
        }

        return const LoginView();
      },
    );
  }
}