import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/auth/presentation/forgot_password_screen.dart';
import '../../screens/auth/presentation/login_screen.dart';
import '../../screens/auth/presentation/signup_screen.dart';
import '../../screens/auth/presentation/splash_screen.dart';
import '../../screens/dashboard/presentation/dashboard_screen.dart';
import '../../screens/dashboard/presentation/home_screen.dart';
import '../../screens/courses/presentation/course_list_screen.dart';
import '../../screens/courses/presentation/course_detail_screen.dart';
import '../../screens/courses/presentation/module_player_screen.dart';
import '../../screens/courses/presentation/assessment_question_screen.dart';
import '../../screens/courses/presentation/code_challenge_screen.dart';
import '../../screens/courses/presentation/score_screen.dart';
import '../../screens/courses/presentation/score_preview_screen.dart';
import '../../screens/courses/presentation/certificate_screen.dart';
import '../../screens/courses/presentation/course_video_screen.dart';
import '../../screens/support/presentation/support_screen.dart';
import '../../screens/profile/presentation/profile_screen.dart';
import '../../screens/profile/presentation/profile_edit_screen.dart';
import '../../screens/subscription/subscription_overview_screen.dart';
import '../../screens/subscription/payment_summary_screen.dart';
import '../../screens/subscription/payment_methods_screen.dart';
import '../../screens/subscription/payment_upi_screen.dart';
import '../../screens/subscription/payment_result_screen.dart';

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
            builder: (context, state) => const CourseListScreen(),
          ),
          GoRoute(
            path: 'courses/:id',
            name: 'dashboardCourseDetail',
            builder: (context, state) => CourseDetailScreen(courseId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'assessment/question',
                name: 'dashboardAssessmentQuestion',
                builder: (context, state) => AssessmentQuestionScreen(courseId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'assessment/score',
                name: 'dashboardAssessmentScore',
                builder: (context, state) {
                  final score = state.extra is int ? state.extra as int : 0;
                  return ScoreScreen(courseId: state.pathParameters['id']!, score: score, total: 10);
                },
              ),
              GoRoute(
                path: 'assessment/preview',
                name: 'dashboardAssessmentPreview',
                builder: (context, state) {
                  final score = state.extra is int ? state.extra as int : 0;
                  return ScorePreviewScreen(courseId: state.pathParameters['id']!, score: score);
                },
              ),
              GoRoute(
                path: 'code',
                name: 'dashboardCodeChallenge',
                builder: (context, state) => CodeChallengeScreen(courseId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'certificate',
                name: 'dashboardCertificate',
                builder: (context, state) => CertificateScreen(courseId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'module/:moduleId/video',
                name: 'dashboardModuleVideo',
                builder: (context, state) {
                  final url = state.uri.queryParameters['url'] ?? '';
                  return CourseVideoScreen(videoUrl: url);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'courses/:courseId/module/:moduleId',
            name: 'dashboardModulePlayer',
            builder: (context, state) => ModulePlayerScreen(
              courseId: state.pathParameters['courseId']!,
              moduleId: state.pathParameters['moduleId']!,
            ),
          ),
          GoRoute(
            path: 'profile',
            name: 'dashboardProfile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'dashboardProfileEdit',
                builder: (context, state) => const ProfileEditScreen(),
              )
            ],
          ),
          /// Subscription flow nested under dashboard to keep BottomNavigation visible
          GoRoute(
            path: 'subscription',
            name: 'dashboardSubscription',
            builder: (context, state) => const SubscriptionOverviewScreen(),
            routes: [
              GoRoute(
                path: 'summary',
                name: 'dashboardPaymentSummary',
                builder: (context, state) => const PaymentSummaryScreen(),
              ),
              GoRoute(
                path: 'methods',
                name: 'dashboardPaymentMethods',
                builder: (context, state) => const PaymentMethodsScreen(),
              ),
              GoRoute(
                path: 'upi',
                name: 'dashboardPaymentUpi',
                builder: (context, state) => const PaymentUpiScreen(),
              ),
              GoRoute(
                path: 'result',
                name: 'dashboardPaymentResult',
                builder: (context, state) => const PaymentResultScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'support',
            name: 'dashboardSupport',
            builder: (context, state) => const SupportScreen(),
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


