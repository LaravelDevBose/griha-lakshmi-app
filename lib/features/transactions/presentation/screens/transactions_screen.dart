import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../income/presentation/screens/add_edit_income_screen.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../controllers/transaction_controller.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final TransactionController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = TransactionController(
      repository: TransactionRepository(
        remoteDataSource: TransactionRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getTransactions();
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

    if (currentPosition >= maxPosition - 260) {
      controller.loadMoreTransactions();
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

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: controller.selectedDateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
    );

    if (picked == null) return;

    controller.changeDateRange(picked);
  }

  Future<void> _openAddIncomeScreen() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditIncomeScreen(),
      ),
    );

    if (saved == true) {
      await controller.getTransactions();
    }
  }

  void _showComingSoonMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.transactions,
      showQuickActionFab: true,
      onIncomeSaved: controller.getTransactions,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null) {
            return _TransactionErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getTransactions,
            );
          }

          final List<TransactionModel> transactions =
              controller.filteredTransactions;

          return RefreshIndicator(
            onRefresh: controller.getTransactions,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 96,
              ),
              children: [
                _MonthlySummaryCard(
                  income: controller.totalIncome,
                  expense: controller.totalExpense,
                  balance: controller.balance,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 12),
                _ActionButtonsRow(
                  onAddIncome: _openAddIncomeScreen,
                  onAddExpense: () {
                    _showComingSoonMessage('Add Expense screen coming next');
                  },
                ),
                const SizedBox(height: 14),
                _SectionTitle(
                  title: 'Filters',
                  trailingText: '${transactions.length} found',
                ),
                const SizedBox(height: 8),
                _FiltersSection(
                  selectedCategory: controller.selectedCategory,
                  selectedMember: controller.selectedMember,
                  selectedAccount: controller.selectedAccount,
                  selectedType: controller.selectedType,
                  selectedDateRange: controller.selectedDateRange,
                  categories: controller.categories,
                  members: controller.members,
                  accounts: controller.accounts,
                  onCategoryChanged: controller.changeCategory,
                  onMemberChanged: controller.changeMember,
                  onAccountChanged: controller.changeAccount,
                  onTypeChanged: controller.changeType,
                  onDateRangeTap: _pickDateRange,
                  onClearDateRange: controller.clearDateRange,
                  formatDate: _formatDate,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'All Transactions',
                ),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  const _EmptyTransactions()
                else
                  ...transactions.map(
                    (TransactionModel transaction) {
                      return _TransactionTile(
                        transaction: transaction,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
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
                if (!controller.hasMorePages && transactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Center(
                      child: Text(
                        'No more transactions',
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

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.formatAmount,
  });

  final double income;
  final double expense;
  final double balance;
  final String Function(double amount) formatAmount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatAmount(balance),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isPositive ? 'Available family balance' : 'Expense crossed income',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.72,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Income',
                  amount: formatAmount(income),
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Expenses',
                  amount: formatAmount(expense),
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  const _SummaryMiniCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.onAddIncome,
    required this.onAddExpense,
  });

  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onAddIncome,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Income'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddExpense,
            icon: const Icon(Icons.remove_rounded, size: 18),
            label: const Text('Add Expense'),
          ),
        ),
      ],
    );
  }
}

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({
    required this.selectedCategory,
    required this.selectedMember,
    required this.selectedAccount,
    required this.selectedType,
    required this.selectedDateRange,
    required this.categories,
    required this.members,
    required this.accounts,
    required this.onCategoryChanged,
    required this.onMemberChanged,
    required this.onAccountChanged,
    required this.onTypeChanged,
    required this.onDateRangeTap,
    required this.onClearDateRange,
    required this.formatDate,
  });

  final String selectedCategory;
  final String selectedMember;
  final String selectedAccount;
  final String selectedType;
  final DateTimeRange? selectedDateRange;
  final List<String> categories;
  final List<String> members;
  final List<String> accounts;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onMemberChanged;
  final ValueChanged<String> onAccountChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onDateRangeTap;
  final VoidCallback onClearDateRange;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
    final String dateText = selectedDateRange == null
        ? 'Date range'
        : '${formatDate(selectedDateRange!.start)} - ${formatDate(selectedDateRange!.end)}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DropdownFilter(
                label: 'Category',
                value: selectedCategory,
                items: categories,
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DropdownFilter(
                label: 'Member',
                value: selectedMember,
                items: members,
                onChanged: onMemberChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DropdownFilter(
                label: 'Account',
                value: selectedAccount,
                items: accounts,
                onChanged: onAccountChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DropdownFilter(
                label: 'Type',
                value: selectedType,
                items: const ['All', 'Income', 'Expense'],
                onChanged: onTypeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _DateRangeFilter(
          text: dateText,
          hasValue: selectedDateRange != null,
          onTap: onDateRangeTap,
          onClear: onClearDateRange,
        ),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : 'All',
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.42,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
      ),
      items: items.map(
        (String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ).toList(),
      onChanged: (String? value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  const _DateRangeFilter({
    required this.text,
    required this.hasValue,
    required this.onTap,
    required this.onClear,
  });

  final String text;
  final bool hasValue;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.42,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.60),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.formatAmount,
    required this.formatDate,
  });

  final TransactionModel transaction;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isIncome = transaction.isIncome;
    final IconData icon =
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final String amountPrefix = isIncome ? '+' : '-';
    final Color transactionColor = isIncome ? Colors.green : Colors.red;

    return Container(
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
              color: transactionColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 19,
              color: transactionColor,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.category} • ${transaction.member} • ${transaction.account}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
                '$amountPrefix${formatAmount(transaction.amount)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: transactionColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDate(transaction.date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.44),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 38,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 8),
          Text(
            'No transactions found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing your filters or add a new transaction.',
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

class _TransactionErrorState extends StatelessWidget {
  const _TransactionErrorState({
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
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
                'Unable to load transactions',
                textAlign: TextAlign.center,
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
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}