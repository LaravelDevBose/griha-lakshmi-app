import 'package:flutter/material.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';

// Later create these screens and uncomment imports
// import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
// import '../features/expense/presentation/screens/add_expense_screen.dart';
// import '../features/income/presentation/screens/add_income_screen.dart';
// import '../features/bills/presentation/screens/bills_screen.dart';
// import '../features/reports/presentation/screens/reports_screen.dart';
// import '../features/profile/presentation/screens/profile_screen.dart';

// Development Preview
import '../features/dev_preview/presentation/screens/widget_preview_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String familySetup = '/family-setup';
  static const String dashboard = '/dashboard';
  static const String addExpense = '/add-expense';

  static const String addIncome = '/add-income';
  static const String bills = '/bills';
  static const String reports = '/reports';
  static const String savingsGoal = '/savings-goal';
  static const String profile = '/profile';

  static const String widgetPreview = '/widget-preview';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          settings,
          const SplashScreen(),
        );

      case AppRoutes.login:
        return _buildRoute(
          settings,
          const LoginScreen(),
        );

      case AppRoutes.dashboard:
        return _buildRoute(
          settings,
          const DashboardScreen(),
        );
      // Add these after creating screens
      /*
      case AppRoutes.register:
        return _buildRoute(
          settings,
          const RegisterScreen(),
        );

      

      case AppRoutes.addExpense:
        return _buildRoute(
          settings,
          const AddExpenseScreen(),
        );

      case AppRoutes.addIncome:
        return _buildRoute(
          settings,
          const AddIncomeScreen(),
        );

      case AppRoutes.bills:
        return _buildRoute(
          settings,
          const BillsScreen(),
        );

      case AppRoutes.reports:
        return _buildRoute(
          settings,
          const ReportsScreen(),
        );

      case AppRoutes.profile:
        return _buildRoute(
          settings,
          const ProfileScreen(),
        );
      */

      case AppRoutes.widgetPreview:
        return _buildRoute(
          settings,
          const WidgetPreviewScreen(),
        );
      default:
        return _buildRoute(
          settings,
          const _RouteNotFoundScreen(),
        );
    }
  }

  static PageRouteBuilder _buildRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Route not found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}