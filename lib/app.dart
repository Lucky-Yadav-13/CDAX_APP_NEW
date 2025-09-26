import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// CDAX App Root
///
/// Uses declarative navigation with GoRouter and applies the shared theme.
class CdaxApp extends StatelessWidget {
  const CdaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.router;

    return MaterialApp.router(
      title: 'CDAX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}


