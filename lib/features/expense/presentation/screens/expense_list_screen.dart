import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../controllers/expense_controller.dart';
import 'add_edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late final ExpenseController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = ExpenseController(
      repository: ExpenseRepository(
        remoteDataSource: ExpenseRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getExpenses();
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
      controller.loadMoreExpenses();
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

  Future<void> _openAddExpense() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditExpenseScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshExpenses();
    }
  }

  Future<void> _openEditExpense(ExpenseModel expense) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditExpenseScreen(
            controller: controller,
            expense: expense,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshExpenses();
    }
  }

  Future<void> _confirmDeleteExpense(ExpenseModel expense) async {
    Navigator.pop(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final bool deleted = await controller.deleteExpense(expense.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? controller.successMessage ?? 'Expense deleted successfully'
              : controller.errorMessage ?? 'Unable to delete expense',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExpenseDetails(ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _ExpenseDetailsBottomSheet(
          expense: expense,
          formatAmount: _formatAmount,
          formatDate: _formatDate,
          onEdit: () => _openEditExpense(expense),
          onDelete: () => _confirmDeleteExpense(expense),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    await controller.refreshExpenses();

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      showQuickActionFab: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Expense'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && controller.expenses.isEmpty) {
            return _ExpenseErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getExpenses,
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
                _ExpenseSummaryCard(
                  totalExpense: controller.totalExpense,
                  totalItems: controller.expenses.length,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Expense List',
                  trailingText: '${controller.expenses.length} found',
                ),
                const SizedBox(height: 8),
                if (controller.expenses.isEmpty)
                  const _EmptyExpenseState()
                else
                  ...controller.expenses.map(
                    (ExpenseModel expense) {
                      return _ExpenseTile(
                        expense: expense,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
                        onTap: () => _showExpenseDetails(expense),
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
                if (!controller.hasMorePages && controller.expenses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more expense records',
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Refreshing expense list...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.totalExpense,
    required this.totalItems,
    required this.formatAmount,
  });

  final double totalExpense;
  final int totalItems;
  final String Function(double amount) formatAmount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const Color expenseColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: expenseColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: expenseColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: expenseColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: expenseColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatAmount(totalExpense),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: expenseColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total expense from $totalItems records',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.formatAmount,
    required this.formatDate,
    required this.onTap,
  });

  final ExpenseModel expense;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const Color expenseColor = Colors.red;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.09),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.018),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: expenseColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 19,
                color: expenseColor,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expense.category} • ${expense.paidBy} • ${expense.paymentAccount}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                      fontWeight: FontWeight.w500,
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
                  '-${formatAmount(expense.amount)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: expenseColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(expense.date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.44),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailsBottomSheet extends StatelessWidget {
  const _ExpenseDetailsBottomSheet({
    required this.expense,
    required this.formatAmount,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseModel expense;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const Color expenseColor = Colors.red;

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
                  color: expenseColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: expenseColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: expenseColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: expenseColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      expense.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '-${formatAmount(expense.amount)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: expenseColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Category', value: expense.category),
              _DetailRow(label: 'Paid By', value: expense.paidBy),
              _DetailRow(
                label: 'Payment Account',
                value: expense.paymentAccount,
              ),
              _DetailRow(label: 'Date', value: formatDate(expense.date)),
              if (expense.receiptImages.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Receipt Images',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppImagePreviewList(
                  imagePaths: expense.receiptImages,
                  height: 86,
                  imageSize: 86,
                  canRemove: false,
                  emptyText: '',
                ),
              ],
              if (expense.notes != null && expense.notes!.trim().isNotEmpty)
                _DetailRow(label: 'Notes', value: expense.notes!),
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
                      text: 'Delete',
                      icon: Icons.delete_rounded,
                      type: AppButtonType.danger,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onDelete,
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

class _EmptyExpenseState extends StatelessWidget {
  const _EmptyExpenseState();

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
            Icons.receipt_long_rounded,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No expense found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first expense record to start tracking.',
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

class _ExpenseErrorState extends StatelessWidget {
  const _ExpenseErrorState({
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
                'Unable to load expense',
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