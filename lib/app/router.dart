import 'package:flutter/material.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';

// Later create these screens and uncomment imports
// import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../features/transactions/presentation/screens/transactions_screen.dart';

import '../features/expense/presentation/screens/expense_list_screen.dart';
import '../features/expense/presentation/screens/add_edit_expense_screen.dart';

import '../features/income/presentation/screens/income_list_screen.dart';
import '../features/income/presentation/screens/add_edit_income_screen.dart';

import '../features/planner/presentation/screens/planner_screen.dart';
import '../../features/purchase_planner/presentation/screens/purchase_planner_list_screen.dart';
import '../features/bills/presentation/screens/bill_list_screen.dart';
import '../features/loans/presentation/screens/loan_list_screen.dart';
import '../features/credit_cards/presentation/screens/credit_card_list_screen.dart';
import '../features/savings_goals/presentation/screens/savings_goal_list_screen.dart';
import '../features/budgets/presentation/screens/budget_screen.dart';

import '../features/reminders/presentation/screens/reminder_list_screen.dart';

// import '../features/reports/presentation/screens/reports_screen.dart';

import '../features/more/presentation/screens/more_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
// Development Preview
import '../features/dev_preview/presentation/screens/widget_preview_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String familySetup = '/family-setup';
  static const String home = '/dashboard';

  static const String transactions = '/transactions';
  static const String incomes = '/incomes';
  static const String addIncome = '/add-income';

  static const String expense = '/expense';
  static const String addExpense = '/add-expense';

  static const String planner = '/planner';

  static const String purchasePlanner = '/purchase-planner';
  static const String loans = '/loans';
  static const String creditCards = '/credit-cards';
  static const String addCreditCard = '/add-credit-card';
  static const String budgets = '/budgets';
    static const String bills = '/bills';

  static const String reminders = '/reminders';


  static const String reports = '/reports';
  static const String savingsGoal = '/savings-goal';
  static const String profile = '/profile';

  static const String more = '/more';

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

      case AppRoutes.home:
        return _buildRoute(
          settings,
          const DashboardScreen(),
        );
      case AppRoutes.transactions:
        return _buildRoute(
          settings,
          const TransactionsScreen(),
        );
      case AppRoutes.incomes:
        return _buildRoute(
          settings,
          const IncomeListScreen(),
        );
      case AppRoutes.addIncome:
        return _buildRoute(
          settings,
          const AddEditIncomeScreen(),
        );
      case AppRoutes.expense:
        return _buildRoute(
          settings,
          const ExpenseListScreen(),
        );
      case AppRoutes.addExpense:
        return _buildRoute(
          settings,
          const AddEditExpenseScreen(),
        );
      case AppRoutes.planner:
        return MaterialPageRoute(
          builder: (_) => const PlannerScreen(),
          settings: settings,
        );
      case AppRoutes.bills:
        return _buildRoute(
          settings,
          const BillListScreen(),
        );
      case AppRoutes.purchasePlanner:
        return _buildRoute(
          settings,
          const PurchasePlannerListScreen(),
        );
      case AppRoutes.loans:
        return _buildRoute(
          settings,
          const LoanListScreen(),
        );
      case AppRoutes.creditCards:
        return _buildRoute(
          settings,
          const CreditCardListScreen(),
        );
      case AppRoutes.savingsGoal:
        return _buildRoute(
          settings,
          const SavingsGoalListScreen(),
        );
      case AppRoutes.budgets:
        return _buildRoute(
          settings,
          const BudgetScreen(),
        );
      case AppRoutes.reminders:
        return _buildRoute(
          settings,
          const ReminderListScreen(),
        );
      case AppRoutes.more:
        return MaterialPageRoute(
          builder: (_) => const MoreScreen(),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      // Add these after creating screens
      /*
      case AppRoutes.register:
        return _buildRoute(
          settings,
          const RegisterScreen(),
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