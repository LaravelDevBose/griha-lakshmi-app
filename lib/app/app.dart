import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'router.dart';
import 'theme.dart';

class FamilyFundApp extends StatelessWidget {
  const FamilyFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}