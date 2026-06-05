import 'dashboard_summary.dart';
import 'expense_category.dart';
import 'recent_transaction.dart';

class Dashboard {
  const Dashboard({
    required this.month,
    required this.summary,
    required this.expenseCategories,
    required this.recentTransactions,
  });

  final String month;
  final DashboardSummary summary;
  final List<ExpenseCategory> expenseCategories;
  final List<RecentTransaction> recentTransactions;

  bool get isEmpty {
    return summary.isEmpty &&
        expenseCategories.isEmpty &&
        recentTransactions.isEmpty;
  }
}