import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/auth/presentation/forgot_password_screen.dart';
import '../../screens/auth/presentation/login_screen.dart';
import '../../screens/auth/presentation/signup_screen.dart';
import '../../screens/auth/presentation/splash_screen.dart';
import '../../screens/dashboard/presentation/dashboard_screen.dart';
import '../../screens/dashboard/presentation/home_screen.dart';

/// Centralized application router using GoRouter
/// Defines all app routes and navigation logic.
class AppRouter {
  AppRouter._();

  /// Global navigator key if needed in the future for dialogs, etc.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: <GoRoute>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      /// Dashboard routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'home',
            name: 'dashboardHome',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: 'courses',
            name: 'dashboardCourses',
            builder: (context, state) => const _DashboardPlaceholder(title: 'Courses list'),
          ),
          GoRoute(
            path: 'courses/:id',
            name: 'dashboardCourseDetail',
            builder: (context, state) => _DashboardPlaceholder(
              title: 'Course: \\${state.pathParameters['id']}',
            ),
          ),
          GoRoute(
            path: 'profile',
            name: 'dashboardProfile',
            builder: (context, state) => const _DashboardPlaceholder(title: 'Profile'),
          ),
          GoRoute(
            path: 'Support',
            name: 'dashboardSupport',
            builder: (context, state) => const _DashboardPlaceholder(title: 'Support'),
          ),
        ],
      ),
    ],
  );
}

/// Simple placeholder for not-yet-implemented sections.
class _DashboardPlaceholder extends StatelessWidget {
  const _DashboardPlaceholder({this.title = 'Dashboard coming soon...'});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}


