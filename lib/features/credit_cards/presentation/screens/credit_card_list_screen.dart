import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/credit_card_remote_datasource.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/repositories/credit_card_repository.dart';
import '../controllers/credit_card_controller.dart';
import 'add_edit_credit_card_screen.dart';

class CreditCardListScreen extends StatefulWidget {
  const CreditCardListScreen({super.key});

  @override
  State<CreditCardListScreen> createState() => _CreditCardListScreenState();
}

class _CreditCardListScreenState extends State<CreditCardListScreen> {
  late final CreditCardController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = CreditCardController(
      repository: CreditCardRepository(
        remoteDataSource: CreditCardRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getCreditCards();
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
      controller.loadMoreCreditCards();
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

  Color _cardStatusColor(CreditCardModel card) {
    if (card.outstandingBalance <= 0) {
      return Colors.green;
    }

    if (card.usedPercentage >= 80) {
      return Colors.red;
    }

    if (card.usedPercentage >= 50) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _openAddCreditCard() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditCreditCardScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshCreditCards();
    }
  }

  Future<void> _openEditCreditCard(CreditCardModel card) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditCreditCardScreen(
            controller: controller,
            creditCard: card,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshCreditCards();
    }
  }

  Future<void> _handleRefresh() async {
    await controller.refreshCreditCards();

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

  Future<void> _recordPayment(CreditCardModel card) async {
    Navigator.pop(context);

    final TextEditingController paymentAmountController = TextEditingController(
      text: card.minimumPayment.toStringAsFixed(0),
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
                      'Record Credit Card Payment',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${card.cardName} • **** ${card.lastFourDigits}',
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
      id: card.id,
      paymentAmount: paymentAmount,
      paymentAccount: selectedAccount,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recorded
              ? controller.successMessage ??
                  'Credit card payment recorded and expense created'
              : controller.errorMessage ?? 'Unable to record payment',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreditCardDetails(CreditCardModel card) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _CreditCardDetailsBottomSheet(
          creditCard: card,
          formatAmount: _formatAmount,
          formatDate: _formatDate,
          statusColor: _cardStatusColor(card),
          onEdit: () => _openEditCreditCard(card),
          onRecordPayment:
              card.canRecordPayment ? () => _recordPayment(card) : null,
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
        onPressed: _openAddCreditCard,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Card'),
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
              controller.creditCards.isEmpty) {
            return _CreditCardErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getCreditCards,
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
                _CreditCardSummaryCard(
                  totalCards: controller.totalCards,
                  totalLimit: controller.totalLimit,
                  totalOutstandingBalance:
                      controller.totalOutstandingBalance,
                  minimumPaymentTotal: controller.minimumPaymentTotal,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Credit Cards',
                  trailingText: '${controller.creditCards.length} found',
                ),
                const SizedBox(height: 8),
                if (controller.creditCards.isEmpty)
                  const _EmptyCreditCardState()
                else
                  ...controller.creditCards.map(
                    (CreditCardModel card) {
                      return _CreditCardTile(
                        creditCard: card,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
                        statusColor: _cardStatusColor(card),
                        onTap: () => _showCreditCardDetails(card),
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
                    controller.creditCards.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more credit cards',
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
              'Refreshing credit cards...',
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

class _CreditCardSummaryCard extends StatelessWidget {
  const _CreditCardSummaryCard({
    required this.totalCards,
    required this.totalLimit,
    required this.totalOutstandingBalance,
    required this.minimumPaymentTotal,
    required this.formatAmount,
  });

  final int totalCards;
  final double totalLimit;
  final double totalOutstandingBalance;
  final double minimumPaymentTotal;
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
            'Credit Cards',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track card limits, dues, minimum payments, and due dates.',
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
                  title: 'Cards',
                  value: totalCards.toString(),
                  icon: Icons.credit_card_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Limit',
                  value: formatAmount(totalLimit),
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Due',
                  value: formatAmount(totalOutstandingBalance),
                  icon: Icons.warning_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AmountInfoRow(
            title: 'Minimum Payment Total',
            value: formatAmount(minimumPaymentTotal),
            icon: Icons.payments_rounded,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _CreditCardTile extends StatelessWidget {
  const _CreditCardTile({
    required this.creditCard,
    required this.formatAmount,
    required this.formatDate,
    required this.statusColor,
    required this.onTap,
  });

  final CreditCardModel creditCard;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double usage = creditCard.usedPercentage / 100;

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
                Icons.credit_card_rounded,
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
                    creditCard.cardName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${creditCard.bankName} • **** ${creditCard.lastFourDigits}',
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
                      value: usage,
                      minHeight: 6,
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${creditCard.usedPercentage.toStringAsFixed(0)}% used • Due ${formatDate(creditCard.nextDueDate)}',
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
                  formatAmount(creditCard.outstandingBalance),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Min ${formatAmount(creditCard.minimumPayment)}',
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

class _CreditCardDetailsBottomSheet extends StatelessWidget {
  const _CreditCardDetailsBottomSheet({
    required this.creditCard,
    required this.formatAmount,
    required this.formatDate,
    required this.statusColor,
    required this.onEdit,
    required this.onRecordPayment,
  });

  final CreditCardModel creditCard;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color statusColor;
  final VoidCallback onEdit;
  final VoidCallback? onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double usage = creditCard.usedPercentage / 100;

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
                        Icons.credit_card_rounded,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      creditCard.cardName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '**** ${creditCard.lastFourDigits}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatAmount(creditCard.outstandingBalance),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Outstanding Balance',
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
                        value: usage,
                        minHeight: 8,
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${creditCard.usedPercentage.toStringAsFixed(0)}% limit used',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Bank Name', value: creditCard.bankName),
              _DetailRow(
                label: 'Credit Limit',
                value: formatAmount(creditCard.creditLimit),
              ),
              _DetailRow(
                label: 'Available Limit',
                value: formatAmount(creditCard.availableLimit),
              ),
              _DetailRow(
                label: 'Minimum Payment',
                value: formatAmount(creditCard.minimumPayment),
              ),
              _DetailRow(
                label: 'Next Due Date',
                value: formatDate(creditCard.nextDueDate),
              ),
              _DetailRow(
                label: 'Statement Day',
                value: 'Every ${creditCard.statementDay} day',
              ),
              _DetailRow(
                label: 'Due Day',
                value: 'Every ${creditCard.dueDay} day',
              ),
              _DetailRow(
                label: 'Assigned Person',
                value: creditCard.assignedPerson,
              ),
              _DetailRow(
                label: 'Reminder',
                value:
                    '${creditCard.reminderDaysBefore} day(s) before at ${creditCard.reminderTime}',
              ),
              _DetailRow(label: 'Status', value: creditCard.status),
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

class _EmptyCreditCardState extends StatelessWidget {
  const _EmptyCreditCardState();

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
            Icons.credit_card_rounded,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No credit card found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first credit card using only last four digits.',
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

class _CreditCardErrorState extends StatelessWidget {
  const _CreditCardErrorState({
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
                'Unable to load credit cards',
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