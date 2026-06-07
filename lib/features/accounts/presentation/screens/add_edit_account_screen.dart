import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';
import '../controllers/account_controller.dart';

class AddEditAccountScreen extends StatefulWidget {
  const AddEditAccountScreen({
    this.controller,
    this.account,
    super.key,
  });

  final AccountController? controller;
  final AccountModel? account;

  bool get isEdit => account != null;

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final AccountController controller;
  late final bool shouldDisposeController;

  late final TextEditingController accountNameController;
  late final TextEditingController institutionNameController;
  late final TextEditingController lastFourDigitsController;
  late final TextEditingController openingBalanceController;
  late final TextEditingController currentBalanceController;
  late final TextEditingController currencyController;
  late final TextEditingController notesController;

  late String selectedAccountType;
  late bool isDefault;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = AccountController(
        repository: AccountRepository(
          remoteDataSource: AccountRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final AccountModel? account = widget.account;

    accountNameController = TextEditingController(
      text: account?.accountName ?? '',
    );

    institutionNameController = TextEditingController(
      text: account?.institutionName ?? '',
    );

    lastFourDigitsController = TextEditingController(
      text: account?.accountNumberLastFour ?? '',
    );

    openingBalanceController = TextEditingController(
      text: account == null ? '' : account.openingBalance.toStringAsFixed(0),
    );

    currentBalanceController = TextEditingController(
      text: account == null ? '' : account.currentBalance.toStringAsFixed(0),
    );

    currencyController = TextEditingController(
      text: account?.currency ?? 'BDT',
    );

    notesController = TextEditingController(
      text: account?.notes ?? '',
    );

    selectedAccountType = _safeInitialAccountType(account?.accountType);
    isDefault = account?.isDefault ?? false;
  }

  @override
  void dispose() {
    accountNameController.dispose();
    institutionNameController.dispose();
    lastFourDigitsController.dispose();
    openingBalanceController.dispose();
    currentBalanceController.dispose();
    currencyController.dispose();
    notesController.dispose();

    if (shouldDisposeController) {
      controller.dispose();
    }

    super.dispose();
  }

  String _safeInitialAccountType(String? value) {
    final bool exists = controller.accountTypes.any(
      (Map<String, String> item) => item['value'] == value,
    );

    if (value != null && exists) {
      return value;
    }

    return controller.accountTypes.first['value'] ?? 'cash';
  }

  bool get _shouldShowInstitution {
    return selectedAccountType == 'bank' ||
        selectedAccountType == 'mobile_banking' ||
        selectedAccountType == 'card' ||
        selectedAccountType == 'wallet';
  }

  bool get _shouldShowLastFour {
    return selectedAccountType == 'bank' ||
        selectedAccountType == 'mobile_banking' ||
        selectedAccountType == 'card' ||
        selectedAccountType == 'wallet';
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

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final double openingBalance =
        double.tryParse(openingBalanceController.text.trim()) ?? 0;

    final double currentBalance =
        double.tryParse(currentBalanceController.text.trim()) ?? 0;

    final String notes =
        notesController.text.trim().isEmpty ? '' : notesController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateAccount(
        id: widget.account!.id,
        accountName: accountNameController.text.trim(),
        accountType: selectedAccountType,
        institutionName: institutionNameController.text.trim(),
        accountNumberLastFour: lastFourDigitsController.text.trim(),
        openingBalance: openingBalance,
        currentBalance: currentBalance,
        currency: currencyController.text.trim().isEmpty
            ? 'BDT'
            : currencyController.text.trim().toUpperCase(),
        isDefault: isDefault,
        status: widget.account!.status,
        notes: notes,
      );
    } else {
      success = await controller.storeAccount(
        accountName: accountNameController.text.trim(),
        accountType: selectedAccountType,
        institutionName: institutionNameController.text.trim(),
        accountNumberLastFour: lastFourDigitsController.text.trim(),
        openingBalance: openingBalance,
        currentBalance: currentBalance,
        currency: currencyController.text.trim().isEmpty
            ? 'BDT'
            : currencyController.text.trim().toUpperCase(),
        isDefault: isDefault,
        notes: notes,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ??
                  (widget.isEdit
                      ? 'Account updated successfully'
                      : 'Account saved successfully')
              : controller.errorMessage ?? 'Something went wrong',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accountColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Account' : 'Add Account',
      showDrawer: false,
      showFooter: false,
      useCustomHeader: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 24,
              ),
              children: [
                _HeaderCard(
                  isEdit: widget.isEdit,
                  color: accountColor,
                  icon: _accountIcon(selectedAccountType),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: accountNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'Example: Cash in Hand',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter account name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Account Type',
                  value: selectedAccountType,
                  items: controller.accountTypes,
                  onChanged: (String value) {
                    setState(() {
                      selectedAccountType = value;

                      if (value == 'cash') {
                        institutionNameController.clear();
                        lastFourDigitsController.clear();
                      }
                    });
                  },
                ),
                if (_shouldShowInstitution) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: institutionNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Institution Name',
                      hintText: 'Example: DBBL, bKash, Nagad',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      if (!_shouldShowInstitution) return null;

                      if (value == null || value.trim().isEmpty) {
                        return 'Enter institution name';
                      }

                      return null;
                    },
                  ),
                ],
                if (_shouldShowLastFour) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastFourDigitsController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Last Four Digits Optional',
                      hintText: 'Never store full account/card number',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final String digits = value?.trim() ?? '';

                      if (digits.isEmpty) return null;

                      if (digits.length != 4) {
                        return 'Enter exactly 4 digits';
                      }

                      if (int.tryParse(digits) == null) {
                        return 'Only digits are allowed';
                      }

                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: openingBalanceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Opening Balance',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? -1;

                    if (amount < 0) {
                      return 'Enter valid opening balance';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: currentBalanceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Current Balance',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? -1;

                    if (amount < 0) {
                      return 'Enter valid current balance';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: currencyController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    hintText: 'BDT',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter currency';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DefaultSwitchTile(
                  value: isDefault,
                  onChanged: (bool value) {
                    setState(() {
                      isDefault = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes Optional',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorMessageBox(
                    message: controller.errorMessage!,
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: widget.isEdit ? 'Update Account' : 'Save Account',
                  icon: widget.isEdit ? Icons.check_rounded : Icons.save_rounded,
                  isLoading: controller.isSubmitting,
                  onPressed: controller.isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Cancel',
                  type: AppButtonType.outline,
                  onPressed:
                      controller.isSubmitting ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.isEdit,
    required this.color,
    required this.icon,
  });

  final bool isEdit;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update account details, balance, and default status'
                  : 'Create an account for income, expense, bill, and planner payments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> safeItems = items.isEmpty
        ? [
            {'value': 'cash', 'label': 'Cash'}
          ]
        : items;

    final bool exists = safeItems.any(
      (Map<String, String> item) => item['value'] == value,
    );

    final String safeValue = exists ? value : safeItems.first['value']!;

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ).copyWith(
        labelText: label,
      ),
      items: safeItems.map((Map<String, String> item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(
            item['label'] ?? item['value'] ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _DefaultSwitchTile extends StatelessWidget {
  const _DefaultSwitchTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.14),
          ),
        ),
        child: SwitchListTile(
          value: value,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          title: Text(
            'Set as Default Account',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            'Default account will be pre-selected in transaction forms.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ErrorMessageBox extends StatelessWidget {
  const _ErrorMessageBox({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}