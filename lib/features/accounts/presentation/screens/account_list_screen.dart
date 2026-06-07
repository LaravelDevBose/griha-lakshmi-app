import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';
import '../controllers/account_controller.dart';
import 'add_edit_account_screen.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late final AccountController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = AccountController(
      repository: AccountRepository(
        remoteDataSource: AccountRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getAccounts();
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
      controller.loadMoreAccounts();
    }
  }

  String _formatAmount(double amount, {String currency = 'BDT'}) {
    if (currency == 'BDT') {
      return '৳${amount.toStringAsFixed(0)}';
    }

    return '$currency ${amount.toStringAsFixed(0)}';
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'mobile_banking':
        return Icons.phone_iphone_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _accountColor(AccountModel account) {
    if (!account.isActive) {
      return Colors.grey;
    }

    switch (account.accountType) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Theme.of(context).colorScheme.primary;
      case 'mobile_banking':
        return Colors.purple;
      case 'card':
        return Colors.orange;
      case 'wallet':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Future<void> _openAddAccount() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditAccountScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshAccounts();
    }
  }

  Future<void> _openEditAccount(AccountModel account) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditAccountScreen(
            controller: controller,
            account: account,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshAccounts();
    }
  }

  Future<void> _handleRefresh() async {
    await controller.refreshAccounts();

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

  Future<void> _setDefault(AccountModel account) async {
    Navigator.pop(context);

    if (account.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This account is already default'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bool success = await controller.setDefaultAccount(account.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ?? 'Default account updated'
              : controller.errorMessage ?? 'Unable to update default account',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deactivateAccount(AccountModel account) async {
    Navigator.pop(context);

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.block_rounded,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Deactivate account?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This account will stay in history, but cannot be selected for new transactions.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  text: 'Deactivate',
                  icon: Icons.block_rounded,
                  type: AppButtonType.danger,
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

    if (confirmed != true) return;

    final bool success = await controller.deactivateAccount(account.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ?? 'Account deactivated'
              : controller.errorMessage ?? 'Unable to deactivate account',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAccountDetails(AccountModel account) {
    final Color color = _accountColor(account);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _AccountDetailsBottomSheet(
          account: account,
          color: color,
          icon: _accountIcon(account.accountType),
          formatAmount: _formatAmount,
          onEdit: () => _openEditAccount(account),
          onSetDefault: account.isActive ? () => _setDefault(account) : null,
          onDeactivate:
              account.isActive ? () => _deactivateAccount(account) : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accounts',
      showDrawer: false,
      showFooter: false,
      useCustomHeader: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAccount,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Account'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && controller.accounts.isEmpty) {
            return _AccountErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getAccounts,
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 96,
              ),
              children: [
                if (controller.isRefreshing) const _TopRefreshLoader(),
                _AccountSummaryCard(
                  totalAccounts: controller.totalAccounts,
                  activeAccounts: controller.activeAccounts,
                  totalBalance: controller.totalBalance,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Account List',
                  trailingText: '${controller.accounts.length} found',
                ),
                const SizedBox(height: 8),
                if (controller.accounts.isEmpty)
                  const _EmptyAccountState()
                else
                  ...controller.accounts.map(
                    (AccountModel account) {
                      return _AccountTile(
                        account: account,
                        color: _accountColor(account),
                        icon: _accountIcon(account.accountType),
                        formatAmount: _formatAmount,
                        onTap: () => _showAccountDetails(account),
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
                if (!controller.hasMorePages && controller.accounts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more accounts',
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
              'Refreshing accounts...',
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

class _AccountSummaryCard extends StatelessWidget {
  const _AccountSummaryCard({
    required this.totalAccounts,
    required this.activeAccounts,
    required this.totalBalance,
    required this.formatAmount,
  });

  final int totalAccounts;
  final int activeAccounts;
  final double totalBalance;
  final String Function(double amount, {String currency}) formatAmount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
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
            'Accounts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage cash, bank, mobile banking, cards, and wallets.',
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
                  value: totalAccounts.toString(),
                  icon: Icons.account_balance_wallet_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Active',
                  value: activeAccounts.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Balance',
                  value: formatAmount(totalBalance),
                  icon: Icons.savings_rounded,
                  color: Colors.orange,
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

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.color,
    required this.icon,
    required this.formatAmount,
    required this.onTap,
  });

  final AccountModel account;
  final Color color;
  final IconData icon;
  final String Function(double amount, {String currency}) formatAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          account.accountName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (account.isDefault) ...[
                        const SizedBox(width: 6),
                        _SmallBadge(
                          text: 'Default',
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    account.institutionName.trim().isEmpty
                        ? account.accountTypeLabel
                        : '${account.accountTypeLabel} • ${account.institutionName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    account.isActive ? 'Active' : 'Inactive',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
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
                  formatAmount(
                    account.currentBalance,
                    currency: account.currency,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
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

class _AccountDetailsBottomSheet extends StatelessWidget {
  const _AccountDetailsBottomSheet({
    required this.account,
    required this.color,
    required this.icon,
    required this.formatAmount,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDeactivate,
  });

  final AccountModel account;
  final Color color;
  final IconData icon;
  final String Function(double amount, {String currency}) formatAmount;
  final VoidCallback onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: color.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      account.accountName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatAmount(
                        account.currentBalance,
                        currency: account.currency,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Current Balance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SmallBadge(
                      text: account.isActive ? 'Active' : 'Inactive',
                      color: color,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Account Type', value: account.accountTypeLabel),
              _DetailRow(
                label: 'Institution',
                value: account.institutionName.trim().isEmpty
                    ? 'Not set'
                    : account.institutionName,
              ),
              _DetailRow(
                label: 'Last Four Digits',
                value: account.accountNumberLastFour.trim().isEmpty
                    ? 'Not set'
                    : '**** ${account.accountNumberLastFour}',
              ),
              _DetailRow(
                label: 'Opening Balance',
                value: formatAmount(
                  account.openingBalance,
                  currency: account.currency,
                ),
              ),
              _DetailRow(
                label: 'Current Balance',
                value: formatAmount(
                  account.currentBalance,
                  currency: account.currency,
                ),
              ),
              _DetailRow(label: 'Currency', value: account.currency),
              _DetailRow(label: 'Default', value: account.isDefault ? 'Yes' : 'No'),
              if (account.notes != null && account.notes!.trim().isNotEmpty)
                _DetailRow(label: 'Notes', value: account.notes!),
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
                      text: 'Default',
                      icon: Icons.star_rounded,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onSetDefault,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Deactivate Account',
                icon: Icons.block_rounded,
                type: AppButtonType.danger,
                onPressed: onDeactivate,
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

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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
              fontWeight: FontWeight.w900,
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

class _EmptyAccountState extends StatelessWidget {
  const _EmptyAccountState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No account found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first account to use it in income, expense, bills, and planner payments.',
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

class _AccountErrorState extends StatelessWidget {
  const _AccountErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppButton(
        text: 'Try Again',
        icon: Icons.refresh_rounded,
        isFullWidth: false,
        onPressed: onRetry,
      ),
    );
  }
}