import 'dashboard_summary.dart';
import 'expense_category.dart';
import 'recent_transaction.dart';
import 'upcoming_reminder.dart';

class Dashboard {
  const Dashboard({
    required this.month,
    required this.summary,
    required this.upcomingReminders,
    required this.expenseCategories,
    required this.recentTransactions,
  });

  final String month;
  final DashboardSummary summary;
  final List<UpcomingReminder> upcomingReminders;
  final List<ExpenseCategory> expenseCategories;
  final List<RecentTransaction> recentTransactions;

  bool get isEmpty {
    return summary.isEmpty &&
        upcomingReminders.isEmpty &&
        expenseCategories.isEmpty &&
        recentTransactions.isEmpty;
  }

  List<UpcomingReminder> get todayReminders {
    return upcomingReminders.where((item) => item.isToday).toList();
  }
}