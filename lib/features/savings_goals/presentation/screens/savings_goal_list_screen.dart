import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/savings_goal_remote_datasource.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/repositories/savings_goal_repository.dart';
import '../controllers/savings_goal_controller.dart';
import 'add_edit_savings_goal_screen.dart';

class SavingsGoalListScreen extends StatefulWidget {
  const SavingsGoalListScreen({super.key});

  @override
  State<SavingsGoalListScreen> createState() => _SavingsGoalListScreenState();
}

class _SavingsGoalListScreenState extends State<SavingsGoalListScreen> {
  late final SavingsGoalController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = SavingsGoalController(
      repository: SavingsGoalRepository(
        remoteDataSource: SavingsGoalRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getSavingsGoals();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final double currentPosition = scrollController.position.pixels;
    final double maxPosition = scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 240) {
      controller.loadMoreSavingsGoals();
    }
  }

  String _formatAmount(double amount) {
    return '৳${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Color _goalColor(SavingsGoalModel goal) {
    if (goal.isCompleted) {
      return Colors.green;
    }

    if (goal.progressPercentage >= 75) {
      return Colors.blue;
    }

    if (goal.progressPercentage >= 40) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _openAddGoal() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditSavingsGoalScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshSavingsGoals();
    }
  }

  Future<void> _openEditGoal(SavingsGoalModel goal) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditSavingsGoalScreen(
            controller: controller,
            savingsGoal: goal,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshSavingsGoals();
    }
  }

  Future<void> _handleRefresh() async {
    await controller.refreshSavingsGoals();

    if (!mounted) return;

    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _recordDeposit(SavingsGoalModel goal) async {
    Navigator.pop(context);

    final TextEditingController depositAmountController = TextEditingController(
      text: goal.monthlyDepositTarget.toStringAsFixed(0),
    );

    String selectedAccount = controller.accounts.first;

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Record Savings Deposit',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      goal.goalName,
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                            color: Theme.of(sheetContext)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.60),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: depositAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Deposit Amount',
                        prefixText: '৳ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: controller.accounts.contains(selectedAccount)
                          ? selectedAccount
                          : controller.accounts.first,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        border: OutlineInputBorder(),
                      ),
                      items: controller.accounts.map((String account) {
                        return DropdownMenuItem<String>(
                          value: account,
                          child: Text(account),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value == null) return;

                        setSheetState(() {
                          selectedAccount = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Save Deposit',
                      icon: Icons.check_circle_rounded,
                      onPressed: () => Navigator.pop(sheetContext, true),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Cancel',
                      type: AppButtonType.outline,
                      onPressed: () => Navigator.pop(sheetContext, false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) {
      depositAmountController.dispose();
      return;
    }

    final double depositAmount =
        double.tryParse(depositAmountController.text.trim()) ?? 0;

    depositAmountController.dispose();

    if (depositAmount <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid deposit amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bool recorded = await controller.recordDeposit(
      id: goal.id,
      depositAmount: depositAmount,
      account: selectedAccount,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recorded
              ? controller.successMessage ?? 'Savings deposit recorded'
              : controller.errorMessage ?? 'Unable to record deposit',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGoalDetails(SavingsGoalModel goal) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _SavingsGoalDetailsBottomSheet(
          goal: goal,
          formatAmount: _formatAmount,
          formatDate: _formatDate,
          goalColor: _goalColor(goal),
          onEdit: () => _openEditGoal(goal),
          onRecordDeposit:
              goal.canRecordDeposit ? () => _recordDeposit(goal) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.planner,
      showQuickActionFab: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddGoal,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Goal'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null &&
              controller.savingsGoals.isEmpty) {
            return _SavingsGoalErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getSavingsGoals,
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 96,
              ),
              children: [
                if (controller.isRefreshing) const _TopRefreshLoader(),
                _SavingsGoalSummaryCard(
                  totalGoals: controller.totalGoals,
                  activeGoals: controller.activeGoals,
                  completedGoals: controller.completedGoals,
                  targetTotal: controller.targetTotal,
                  currentTotal: controller.currentTotal,
                  monthlyTargetTotal: controller.monthlyTargetTotal,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Savings Goals',
                  trailingText: '${controller.savingsGoals.length} found',
                ),
                const SizedBox(height: 8),
                if (controller.savingsGoals.isEmpty)
                  const _EmptySavingsGoalState()
                else
                  ...controller.savingsGoals.map(
                    (SavingsGoalModel goal) {
                      return _SavingsGoalTile(
                        goal: goal,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
                        goalColor: _goalColor(goal),
                        onTap: () => _showGoalDetails(goal),
                      );
                    },
                  ),
                if (controller.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                  ),
                if (!controller.hasMorePages &&
                    controller.savingsGoals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more savings goals',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopRefreshLoader extends StatelessWidget {
  const _TopRefreshLoader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Refreshing savings goals...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalSummaryCard extends StatelessWidget {
  const _SavingsGoalSummaryCard({
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
    required this.targetTotal,
    required this.currentTotal,
    required this.monthlyTargetTotal,
    required this.formatAmount,
  });

  final int totalGoals;
  final int activeGoals;
  final int completedGoals;
  final double targetTotal;
  final double currentTotal;
  final double monthlyTargetTotal;
  final String Function(double amount) formatAmount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Savings Goals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track family savings targets, deposits, and progress.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Goals',
                  value: totalGoals.toString(),
                  icon: Icons.savings_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Active',
                  value: activeGoals.toString(),
                  icon: Icons.flag_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Done',
                  value: completedGoals.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AmountInfoRow(
            title: 'Current Saved',
            value: formatAmount(currentTotal),
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 8),
          _AmountInfoRow(
            title: 'Target Total',
            value: formatAmount(targetTotal),
            icon: Icons.track_changes_rounded,
          ),
          const SizedBox(height: 8),
          _AmountInfoRow(
            title: 'Monthly Target',
            value: formatAmount(monthlyTargetTotal),
            icon: Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalTile extends StatelessWidget {
  const _SavingsGoalTile({
    required this.goal,
    required this.formatAmount,
    required this.formatDate,
    required this.goalColor,
    required this.onTap,
  });

  final SavingsGoalModel goal;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color goalColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = goal.progressPercentage / 100;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.09),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.018),
              blurRadius: 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: goalColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.savings_rounded,
                color: goalColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.goalName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${goal.goalType} • Next ${formatDate(goal.nextDepositDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: goalColor.withValues(alpha: 0.12),
                      color: goalColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(0)}% saved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatAmount(goal.currentAmount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'of ${formatAmount(goal.targetAmount)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsGoalDetailsBottomSheet extends StatelessWidget {
  const _SavingsGoalDetailsBottomSheet({
    required this.goal,
    required this.formatAmount,
    required this.formatDate,
    required this.goalColor,
    required this.onEdit,
    required this.onRecordDeposit,
  });

  final SavingsGoalModel goal;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color goalColor;
  final VoidCallback onEdit;
  final VoidCallback? onRecordDeposit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = goal.progressPercentage / 100;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: goalColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: goalColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: goalColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.savings_rounded,
                        color: goalColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      goal.goalName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatAmount(goal.currentAmount),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Saved of ${formatAmount(goal.targetAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.56),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: goalColor.withValues(alpha: 0.12),
                        color: goalColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(0)}% completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: goalColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Goal Type', value: goal.goalType),
              _DetailRow(
                label: 'Target Amount',
                value: formatAmount(goal.targetAmount),
              ),
              _DetailRow(
                label: 'Remaining Amount',
                value: formatAmount(goal.remainingAmount),
              ),
              _DetailRow(
                label: 'Monthly Target',
                value: formatAmount(goal.monthlyDepositTarget),
              ),
              _DetailRow(
                label: 'Next Deposit Date',
                value: formatDate(goal.nextDepositDate),
              ),
              _DetailRow(
                label: 'Deposit Due Day',
                value: 'Every ${goal.depositDueDay} day',
              ),
              _DetailRow(
                label: 'Target Date',
                value: formatDate(goal.targetDate),
              ),
              _DetailRow(
                label: 'Assigned Person',
                value: goal.assignedPerson,
              ),
              _DetailRow(
                label: 'Reminder',
                value:
                    '${goal.reminderDaysBefore} day(s) before at ${goal.reminderTime}',
              ),
              _DetailRow(label: 'Status', value: goal.status),
              if (goal.notes != null && goal.notes!.trim().isNotEmpty)
                _DetailRow(label: 'Notes', value: goal.notes!),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Edit',
                      icon: Icons.edit_rounded,
                      type: AppButtonType.outline,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Deposit',
                      icon: Icons.savings_rounded,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onRecordDeposit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountInfoRow extends StatelessWidget {
  const _AmountInfoRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  const _SummaryMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.trailingText,
  });

  final String title;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _EmptySavingsGoalState extends StatelessWidget {
  const _EmptySavingsGoalState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.savings_rounded,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No savings goal found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first goal to start tracking your savings.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalErrorState extends StatelessWidget {
  const _SavingsGoalErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load savings goals',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Try Again',
                icon: Icons.refresh_rounded,
                isFullWidth: false,
                height: 46,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}