import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/loan_remote_datasource.dart';
import '../../data/models/loan_model.dart';
import '../../data/repositories/loan_repository.dart';
import '../controllers/loan_controller.dart';
import 'add_edit_loan_screen.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  late final LoanController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = LoanController(
      repository: LoanRepository(
        remoteDataSource: LoanRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getLoans();
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
      controller.loadMoreLoans();
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

  Color _statusColor(LoanModel loan) {
    if (loan.isCompleted) {
      return Colors.green;
    }

    return Colors.orange;
  }

  Future<void> _openAddLoan() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditLoanScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshLoans();
    }
  }

  Future<void> _openEditLoan(LoanModel loan) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditLoanScreen(
            controller: controller,
            loan: loan,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshLoans();
    }
  }

  Future<void> _handleRefresh() async {
    await controller.refreshLoans();

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

  Future<void> _recordPayment(LoanModel loan) async {
    Navigator.pop(context);

    final TextEditingController paymentAmountController = TextEditingController(
      text: loan.installmentAmount.toStringAsFixed(0),
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
                      'Record Loan Payment',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loan.loanName,
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
                      controller: paymentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount',
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
                        labelText: 'Payment Account',
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
                      text: 'Save Payment',
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
      paymentAmountController.dispose();
      return;
    }

    final double paymentAmount =
        double.tryParse(paymentAmountController.text.trim()) ?? 0;

    paymentAmountController.dispose();

    if (paymentAmount <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid payment amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bool recorded = await controller.recordPayment(
      id: loan.id,
      paymentAmount: paymentAmount,
      paymentAccount: selectedAccount,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recorded
              ? controller.successMessage ??
                  'Loan payment recorded and expense created'
              : controller.errorMessage ?? 'Unable to record payment',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoanDetails(LoanModel loan) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _LoanDetailsBottomSheet(
          loan: loan,
          formatAmount: _formatAmount,
          formatDate: _formatDate,
          statusColor: _statusColor(loan),
          onEdit: () => _openEditLoan(loan),
          onRecordPayment:
              loan.canRecordPayment ? () => _recordPayment(loan) : null,
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
        onPressed: _openAddLoan,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Loan'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && controller.loans.isEmpty) {
            return _LoanErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getLoans,
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
                _LoanSummaryCard(
                  totalLoans: controller.totalLoans,
                  activeLoans: controller.activeLoans,
                  completedLoans: controller.completedLoans,
                  totalRemainingBalance: controller.totalRemainingBalance,
                  monthlyInstallmentTotal: controller.monthlyInstallmentTotal,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Loans',
                  trailingText: '${controller.loans.length} found',
                ),
                const SizedBox(height: 8),
                if (controller.loans.isEmpty)
                  const _EmptyLoanState()
                else
                  ...controller.loans.map(
                    (LoanModel loan) {
                      return _LoanTile(
                        loan: loan,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
                        statusColor: _statusColor(loan),
                        onTap: () => _showLoanDetails(loan),
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
                if (!controller.hasMorePages && controller.loans.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more loans',
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
              'Refreshing loans...',
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

class _LoanSummaryCard extends StatelessWidget {
  const _LoanSummaryCard({
    required this.totalLoans,
    required this.activeLoans,
    required this.completedLoans,
    required this.totalRemainingBalance,
    required this.monthlyInstallmentTotal,
    required this.formatAmount,
  });

  final int totalLoans;
  final int activeLoans;
  final int completedLoans;
  final double totalRemainingBalance;
  final double monthlyInstallmentTotal;
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
            'Loan Planner',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track loan balances, installments, and upcoming payments.',
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
                  title: 'Total',
                  value: totalLoans.toString(),
                  icon: Icons.account_balance_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Active',
                  value: activeLoans.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Done',
                  value: completedLoans.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AmountInfoRow(
            title: 'Remaining Balance',
            value: formatAmount(totalRemainingBalance),
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 8),
          _AmountInfoRow(
            title: 'Monthly Installments',
            value: formatAmount(monthlyInstallmentTotal),
            icon: Icons.calendar_month_rounded,
          ),
        ],
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

class _LoanTile extends StatelessWidget {
  const _LoanTile({
    required this.loan,
    required this.formatAmount,
    required this.formatDate,
    required this.statusColor,
    required this.onTap,
  });

  final LoanModel loan;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = loan.progressPercentage / 100;

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
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: statusColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.loanName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${loan.lenderName} • Due ${formatDate(loan.nextDueDate)}',
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
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loan.progressPercentage.toStringAsFixed(0)}% paid',
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
                  formatAmount(loan.remainingBalance),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'EMI ${formatAmount(loan.installmentAmount)}',
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

class _LoanDetailsBottomSheet extends StatelessWidget {
  const _LoanDetailsBottomSheet({
    required this.loan,
    required this.formatAmount,
    required this.formatDate,
    required this.statusColor,
    required this.onEdit,
    required this.onRecordPayment,
  });

  final LoanModel loan;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color statusColor;
  final VoidCallback onEdit;
  final VoidCallback? onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = loan.progressPercentage / 100;

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
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loan.loanName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatAmount(loan.remainingBalance),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Remaining Balance',
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
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${loan.progressPercentage.toStringAsFixed(0)}% completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Lender', value: loan.lenderName),
              _DetailRow(
                label: 'Original Amount',
                value: formatAmount(loan.originalAmount),
              ),
              _DetailRow(
                label: 'Monthly Installment',
                value: formatAmount(loan.installmentAmount),
              ),
              _DetailRow(
                label: 'Next Due Date',
                value: formatDate(loan.nextDueDate),
              ),
              _DetailRow(label: 'Due Day', value: 'Every ${loan.dueDay} day'),
              _DetailRow(label: 'Start Date', value: formatDate(loan.startDate)),
              _DetailRow(
                label: 'Expected End Date',
                value: formatDate(loan.expectedEndDate),
              ),
              _DetailRow(label: 'Assigned Person', value: loan.assignedPerson),
              _DetailRow(
                label: 'Interest Rate',
                value: loan.interestRate == null
                    ? 'Not set'
                    : '${loan.interestRate!.toStringAsFixed(2)}%',
              ),
              _DetailRow(
                label: 'Reminder',
                value:
                    '${loan.reminderDaysBefore} day(s) before at ${loan.reminderTime}',
              ),
              _DetailRow(label: 'Status', value: loan.status),
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
                      text: 'Record Pay',
                      icon: Icons.payments_rounded,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onRecordPayment,
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

class _EmptyLoanState extends StatelessWidget {
  const _EmptyLoanState();

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
            Icons.account_balance_rounded,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No loan found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first loan to start tracking installments.',
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

class _LoanErrorState extends StatelessWidget {
  const _LoanErrorState({
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
                'Unable to load loans',
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