import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/assessment_provider.dart';
import 'providers/assessment_result_provider.dart';
import 'providers/placement_provider.dart';
import 'providers/user_provider.dart';
import 'screens/profile/application/profile_provider.dart';

/// CDAX App Root
///
/// Uses declarative navigation with GoRouter and applies the shared theme.
class CdaxApp extends StatelessWidget {
  const CdaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentResultProvider()),
        ChangeNotifierProvider(create: (_) => PlacementProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Initialize user provider once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!userProvider.isLoading) {
              userProvider.initialize();
            }
          });
          
          final GoRouter router = AppRouter.router;
          
          return MaterialApp.router(
            title: 'CDAX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}


