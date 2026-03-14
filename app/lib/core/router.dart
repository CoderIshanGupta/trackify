import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/expenses/expenses_screen.dart';
import '../features/workouts/workouts_screen.dart';
import '../features/mood/mood_screen.dart';
import '../features/profile/profile_screen.dart';
import '../shared/widgets/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final onLogin = state.matchedLocation == '/login';
    if (!isLoggedIn && !onLogin) return '/login';
    if (isLoggedIn && onLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen()),
        GoRoute(path: '/workouts', builder: (_, __) => const WorkoutsScreen()),
        GoRoute(path: '/mood', builder: (_, __) => const MoodScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);
