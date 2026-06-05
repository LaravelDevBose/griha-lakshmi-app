import 'package:flutter/material.dart';

import '../../../../app/app_config.dart';
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
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: _controller.isLoading
              ? null
              : () {
                  _controller.refreshDashboard();
                },
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          onPressed: () async {
            await AuthGuard.logout(context);
          },
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
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
            'Start adding income and expenses to see your family finance overview here.',
        icon: Icons.dashboard_outlined,
        buttonText: 'Add Expense',
        onButtonPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addExpense,
          );
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
        _DashboardGreeting(month: dashboard.month),

        const SizedBox(height: 24),

        _SummaryGrid(dashboard: dashboard),

        const SizedBox(height: 28),

        SectionHeader(
          title: 'Quick Actions',
          subtitle: AppConfig.useMockData
              ? 'Mock mode is active. Data is loaded from JSON.'
              : 'Connected with your API.',
        ),

        const SizedBox(height: 16),

        const _QuickActions(),

        const SizedBox(height: 28),

        const SectionHeader(
          title: 'This Month’s Expenses',
          subtitle: 'Category-wise budget progress.',
        ),

        const SizedBox(height: 16),

        _ExpenseCategoryList(
          categories: dashboard.expenseCategories,
        ),

        const SizedBox(height: 28),

        const SectionHeader(
          title: 'Recent Transactions',
          subtitle: 'Latest income and expense records.',
        ),

        const SizedBox(height: 16),

        _RecentTransactionList(
          transactions: dashboard.recentTransactions,
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting({
    required this.month,
  });

  final String month;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
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
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  month,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.82),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Balance',
                amount: summary.remainingBalance,
                icon: Icons.account_balance_wallet_rounded,
                amountType: AmountTextType.normal,
                subtitle: 'Remaining',
              ),
            ),
            const SizedBox(width: 12),
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
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _QuickActionItem(
            title: 'Add Income',
            icon: Icons.add_card_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.addIncome);
            },
          ),
          _QuickActionItem(
            title: 'Add Expense',
            icon: Icons.receipt_long_outlined,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.addExpense);
            },
          ),
          _QuickActionItem(
            title: 'Bills',
            icon: Icons.payments_outlined,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.bills);
            },
          ),
          _QuickActionItem(
            title: 'Reports',
            icon: Icons.bar_chart_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reports);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              AppIconBox(
                icon: icon,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCategoryList extends StatelessWidget {
  const _ExpenseCategoryList({
    required this.categories,
  });

  final List<ExpenseCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const AppCard(
        child: EmptyState(
          title: 'No expense categories',
          message: 'Add expenses to see category-wise progress.',
          icon: Icons.category_outlined,
        ),
      );
    }

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProgressInfoCard(
            title: category.name,
            subtitle: 'This month spending',
            currentAmount: category.amount,
            targetAmount: category.budget,
            progressColor: _categoryColor(category.icon),
          ),
        );
      }).toList(),
    );
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

class _RecentTransactionList extends StatelessWidget {
  const _RecentTransactionList({
    required this.transactions,
  });

  final List<RecentTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const AppCard(
        child: EmptyState(
          title: 'No transactions yet',
          message: 'Your latest income and expenses will appear here.',
          icon: Icons.receipt_long_outlined,
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TransactionTile(
            title: transaction.title,
            subtitle: transaction.subtitle,
            amount: transaction.amount,
            type: transaction.type == RecentTransactionType.income
                ? TransactionType.income
                : TransactionType.expense,
            icon: _transactionIcon(transaction.icon),
          ),
        );
      }).toList(),
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