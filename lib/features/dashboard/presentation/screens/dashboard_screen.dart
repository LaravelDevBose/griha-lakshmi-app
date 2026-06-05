import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/api/api.dart';
import '../../../../core/auth/auth_guard.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/entities/upcoming_reminder.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ApiClient _apiClient;
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();

    _controller = DashboardController(
      dashboardRepository: DashboardRepositoryImpl(
        remoteDataSource: DashboardRemoteDataSource(
          apiClient: _apiClient,
        ),
      ),
    );

    _controller.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AuthGuard.protectRoute(context);

      if (!mounted) return;

      await _controller.loadDashboard();
    });
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.home,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const LoadingView(
        message: 'Loading your family dashboard...',
      );
    }

    if (_controller.isError) {
      return ErrorView(
        title: 'Could not load dashboard',
        message: _controller.failure?.firstErrorMessage ??
            'Something went wrong. Please try again.',
        onRetry: _controller.refreshDashboard,
      );
    }

    if (_controller.isEmpty) {
      return EmptyState(
        title: 'No dashboard data yet',
        message:
            'Start adding income, expenses and bills to see your family finance overview.',
        icon: Icons.dashboard_outlined,
        buttonText: 'Add Expense',
        onButtonPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
      );
    }

    final Dashboard? dashboard = _controller.dashboard;

    if (dashboard == null) {
      return const EmptyState(
        title: 'No dashboard data',
        message: 'Dashboard information is not available right now.',
        icon: Icons.dashboard_outlined,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _controller.refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _DashboardContent(
          dashboard: dashboard,
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.dashboard,
  });

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardGreeting(
          month: dashboard.month,
          todayCount: dashboard.todayReminders.length,
        ),

        const SizedBox(height: 18),

        _SummaryGrid(dashboard: dashboard),

        const SizedBox(height: 22),

        _UpcomingReminderSection(
          reminders: dashboard.upcomingReminders,
        ),

        const SizedBox(height: 22),

        _ExpenseCategorySection(
          categories: dashboard.expenseCategories,
        ),

        const SizedBox(height: 22),

        _RecentTransactionSection(
          transactions: dashboard.recentTransactions,
        ),

        const SizedBox(height: 26),
      ],
    );
  }
}

class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting({
    required this.month,
    required this.todayCount,
  });

  final String month;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primary,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Arup',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  month,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.80),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (todayCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$todayCount item${todayCount > 1 ? 's' : ''} need attention today',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          AppIconBox(
            icon: Icons.family_restroom_rounded,
            backgroundColor: AppColors.white.withOpacity(0.14),
            iconColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.dashboard,
  });

  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final summary = dashboard.summary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useTwoColumns = constraints.maxWidth >= 340;

        if (!useTwoColumns) {
          return Column(
            children: [
              SummaryCard(
                title: 'Income',
                amount: summary.totalIncome,
                icon: Icons.trending_up_rounded,
                amountType: AmountTextType.income,
                iconBackgroundColor: AppColors.success.withOpacity(0.10),
                iconColor: AppColors.success,
                subtitle: 'This month',
              ),
              const SizedBox(height: 10),
              SummaryCard(
                title: 'Expense',
                amount: summary.totalExpense,
                icon: Icons.trending_down_rounded,
                amountType: AmountTextType.expense,
                iconBackgroundColor: AppColors.danger.withOpacity(0.10),
                iconColor: AppColors.danger,
                subtitle: 'This month',
              ),
              const SizedBox(height: 10),
              SummaryCard(
                title: 'Balance',
                amount: summary.remainingBalance,
                icon: Icons.account_balance_wallet_rounded,
                subtitle: 'Remaining',
              ),
              const SizedBox(height: 10),
              SummaryCard(
                title: 'Savings',
                amount: summary.totalSavings,
                icon: Icons.savings_outlined,
                amountType: AmountTextType.warning,
                iconBackgroundColor: AppColors.warning.withOpacity(0.10),
                iconColor: AppColors.warning,
                subtitle: 'Saved',
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Income',
                    amount: summary.totalIncome,
                    icon: Icons.trending_up_rounded,
                    amountType: AmountTextType.income,
                    iconBackgroundColor: AppColors.success.withOpacity(0.10),
                    iconColor: AppColors.success,
                    subtitle: 'This month',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    title: 'Expense',
                    amount: summary.totalExpense,
                    icon: Icons.trending_down_rounded,
                    amountType: AmountTextType.expense,
                    iconBackgroundColor: AppColors.danger.withOpacity(0.10),
                    iconColor: AppColors.danger,
                    subtitle: 'This month',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Balance',
                    amount: summary.remainingBalance,
                    icon: Icons.account_balance_wallet_rounded,
                    subtitle: 'Remaining',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    title: 'Savings',
                    amount: summary.totalSavings,
                    icon: Icons.savings_outlined,
                    amountType: AmountTextType.warning,
                    iconBackgroundColor: AppColors.warning.withOpacity(0.10),
                    iconColor: AppColors.warning,
                    subtitle: 'Saved',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _UpcomingReminderSection extends StatelessWidget {
  const _UpcomingReminderSection({
    required this.reminders,
  });

  final List<UpcomingReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final List<UpcomingReminder> sortedReminders = [...reminders];

    sortedReminders.sort((a, b) {
      if (a.isToday && !b.isToday) return -1;
      if (!a.isToday && b.isToday) return 1;

      final DateTime aDate = a.dueDate ?? DateTime(2999);
      final DateTime bDate = b.dueDate ?? DateTime(2999);

      return aDate.compareTo(bDate);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Upcoming',
          subtitle: 'Bills and purchase reminders.',
        ),

        const SizedBox(height: 12),

        if (sortedReminders.isEmpty)
          const AppCard(
            showShadow: false,
            child: EmptyState(
              title: 'No upcoming reminder',
              message: 'Bills and purchase reminders will appear here.',
              icon: Icons.notifications_none_rounded,
            ),
          )
        else
          Column(
            children: sortedReminders.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: UpcomingReminderTile(
                  title: item.title,
                  note: item.note,
                  amount: item.amount,
                  dueDate: item.dueDate,
                  icon: _reminderIcon(item.icon),
                  isToday: item.isToday,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  IconData _reminderIcon(String icon) {
    switch (icon) {
      case 'electricity':
        return Icons.electric_bolt_rounded;
      case 'grocery':
        return Icons.shopping_basket_outlined;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'rent':
        return Icons.home_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}

class _ExpenseCategorySection extends StatelessWidget {
  const _ExpenseCategorySection({
    required this.categories,
  });

  final List<ExpenseCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'This Month Expenses',
          subtitle: 'Compact budget progress.',
        ),

        const SizedBox(height: 12),

        if (categories.isEmpty)
          const AppCard(
            showShadow: false,
            child: EmptyState(
              title: 'No expenses yet',
              message: 'Add expenses to see category progress.',
              icon: Icons.category_outlined,
            ),
          )
        else
          Column(
            children: categories.take(4).map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ExpenseProgressTile(
                  title: category.name,
                  amount: category.amount,
                  budget: category.budget,
                  icon: _categoryIcon(category.icon),
                  progressColor: _categoryColor(category.icon),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  IconData _categoryIcon(String icon) {
    switch (icon) {
      case 'grocery':
        return Icons.shopping_basket_outlined;
      case 'rent':
        return Icons.home_outlined;
      case 'electricity':
        return Icons.electric_bolt_rounded;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'family':
        return Icons.family_restroom_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  Color _categoryColor(String icon) {
    switch (icon) {
      case 'medical':
        return AppColors.danger;
      case 'electricity':
        return AppColors.warning;
      case 'family':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }
}

class _RecentTransactionSection extends StatelessWidget {
  const _RecentTransactionSection({
    required this.transactions,
  });

  final List<RecentTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Recent Transactions',
          subtitle: 'Latest records.',
        ),

        const SizedBox(height: 12),

        if (transactions.isEmpty)
          const AppCard(
            showShadow: false,
            child: EmptyState(
              title: 'No transactions',
              message: 'Your income and expense records will appear here.',
              icon: Icons.receipt_long_outlined,
            ),
          )
        else
          Column(
            children: transactions.take(4).map((transaction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CompactTransactionTile(
                  title: transaction.title,
                  subtitle: transaction.subtitle,
                  amount: transaction.amount,
                  type: transaction.type == RecentTransactionType.income
                      ? CompactTransactionType.income
                      : CompactTransactionType.expense,
                  icon: _transactionIcon(transaction.icon),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  IconData _transactionIcon(String icon) {
    switch (icon) {
      case 'salary':
        return Icons.work_outline_rounded;
      case 'rent':
        return Icons.home_outlined;
      case 'grocery':
        return Icons.shopping_cart_outlined;
      case 'medical':
        return Icons.medical_services_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}