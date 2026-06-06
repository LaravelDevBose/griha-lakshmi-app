import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/credit_card_remote_datasource.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/repositories/credit_card_repository.dart';
import '../controllers/credit_card_controller.dart';

class AddEditCreditCardScreen extends StatefulWidget {
  const AddEditCreditCardScreen({
    this.controller,
    this.creditCard,
    super.key,
  });

  final CreditCardController? controller;
  final CreditCardModel? creditCard;

  bool get isEdit => creditCard != null;

  @override
  State<AddEditCreditCardScreen> createState() =>
      _AddEditCreditCardScreenState();
}

class _AddEditCreditCardScreenState extends State<AddEditCreditCardScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final CreditCardController controller;
  late final bool shouldDisposeController;

  late final TextEditingController cardNameController;
  late final TextEditingController bankNameController;
  late final TextEditingController lastFourDigitsController;
  late final TextEditingController creditLimitController;
  late final TextEditingController outstandingBalanceController;
  late final TextEditingController statementDayController;
  late final TextEditingController dueDayController;
  late final TextEditingController minimumPaymentController;
  late final TextEditingController reminderDaysController;

  late String selectedAssignedPerson;
  late TimeOfDay selectedReminderTime;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = CreditCardController(
        repository: CreditCardRepository(
          remoteDataSource: CreditCardRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final CreditCardModel? card = widget.creditCard;

    cardNameController = TextEditingController(
      text: card?.cardName ?? '',
    );

    bankNameController = TextEditingController(
      text: card?.bankName ?? '',
    );

    lastFourDigitsController = TextEditingController(
      text: card?.lastFourDigits ?? '',
    );

    creditLimitController = TextEditingController(
      text: card == null ? '' : card.creditLimit.toStringAsFixed(0),
    );

    outstandingBalanceController = TextEditingController(
      text: card == null ? '' : card.outstandingBalance.toStringAsFixed(0),
    );

    statementDayController = TextEditingController(
      text: card?.statementDay.toString() ?? '1',
    );

    dueDayController = TextEditingController(
      text: card?.dueDay.toString() ?? '1',
    );

    minimumPaymentController = TextEditingController(
      text: card == null ? '' : card.minimumPayment.toStringAsFixed(0),
    );

    reminderDaysController = TextEditingController(
      text: card?.reminderDaysBefore.toString() ?? '1',
    );

    selectedAssignedPerson = _safeInitialValue(
      value: card?.assignedPerson,
      items: controller.members,
    );

    selectedReminderTime = _timeFromString(
      card?.reminderTime ?? '09:00',
    );
  }

  @override
  void dispose() {
    cardNameController.dispose();
    bankNameController.dispose();
    lastFourDigitsController.dispose();
    creditLimitController.dispose();
    outstandingBalanceController.dispose();
    statementDayController.dispose();
    dueDayController.dispose();
    minimumPaymentController.dispose();
    reminderDaysController.dispose();

    if (shouldDisposeController) {
      controller.dispose();
    }

    super.dispose();
  }

  String _safeInitialValue({
    required String? value,
    required List<String> items,
  }) {
    if (value != null && items.contains(value)) {
      return value;
    }

    if (items.isNotEmpty) {
      return items.first;
    }

    return '';
  }

  TimeOfDay _timeFromString(String time) {
    final List<String> parts = time.split(':');

    if (parts.length != 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _timeToString(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatTime(TimeOfDay time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute $period';
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedReminderTime,
    );

    if (picked == null) return;

    setState(() {
      selectedReminderTime = picked;
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final double creditLimit =
        double.tryParse(creditLimitController.text.trim()) ?? 0;

    final double outstandingBalance =
        double.tryParse(outstandingBalanceController.text.trim()) ?? 0;

    final int statementDay =
        int.tryParse(statementDayController.text.trim()) ?? 1;

    final int dueDay = int.tryParse(dueDayController.text.trim()) ?? 1;

    final double minimumPayment =
        double.tryParse(minimumPaymentController.text.trim()) ?? 0;

    final int reminderDays =
        int.tryParse(reminderDaysController.text.trim()) ?? 1;

    bool success;

    if (widget.isEdit) {
      success = await controller.updateCreditCard(
        id: widget.creditCard!.id,
        cardName: cardNameController.text.trim(),
        bankName: bankNameController.text.trim(),
        lastFourDigits: lastFourDigitsController.text.trim(),
        creditLimit: creditLimit,
        outstandingBalance: outstandingBalance,
        statementDay: statementDay,
        dueDay: dueDay,
        minimumPayment: minimumPayment,
        assignedPerson: selectedAssignedPerson,
        reminderDaysBefore: reminderDays,
        reminderTime: _timeToString(selectedReminderTime),
        status: widget.creditCard!.status,
      );
    } else {
      success = await controller.storeCreditCard(
        cardName: cardNameController.text.trim(),
        bankName: bankNameController.text.trim(),
        lastFourDigits: lastFourDigitsController.text.trim(),
        creditLimit: creditLimit,
        outstandingBalance: outstandingBalance,
        statementDay: statementDay,
        dueDay: dueDay,
        minimumPayment: minimumPayment,
        assignedPerson: selectedAssignedPerson,
        reminderDaysBefore: reminderDays,
        reminderTime: _timeToString(selectedReminderTime),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ??
                  (widget.isEdit
                      ? 'Credit card updated successfully'
                      : 'Credit card saved successfully')
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
    final Color cardColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Credit Card' : 'Add Credit Card',
      showDrawer: false,
      showFooter: false,
      showQuickActionFab: false,
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
                  cardColor: cardColor,
                ),
                const SizedBox(height: 14),
                const _SecurityNoticeCard(),
                const SizedBox(height: 14),
                TextFormField(
                  controller: cardNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Card Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter card name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bankNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter bank name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastFourDigitsController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'Last Four Digits',
                    counterText: '',
                    prefixText: '**** ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final String digits = value?.trim() ?? '';

                    if (digits.length != 4) {
                      return 'Enter exactly 4 digits';
                    }

                    if (int.tryParse(digits) == null) {
                      return 'Only digits are allowed';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: creditLimitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Credit Limit',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid credit limit';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: outstandingBalanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Outstanding Balance',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? -1;

                    if (amount < 0) {
                      return 'Enter a valid outstanding balance';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: statementDayController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Statement Day',
                    hintText: 'Example: 5',
                    suffixText: 'day',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final int day = int.tryParse(value?.trim() ?? '') ?? 0;

                    if (day < 1 || day > 28) {
                      return 'Statement day must be between 1 and 28';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dueDayController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Due Day',
                    hintText: 'Example: 20',
                    suffixText: 'day',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final int day = int.tryParse(value?.trim() ?? '') ?? 0;

                    if (day < 1 || day > 28) {
                      return 'Due day must be between 1 and 28';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: minimumPaymentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Payment',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid minimum payment';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Assigned Person',
                  value: selectedAssignedPerson,
                  items: controller.members,
                  onChanged: (String value) {
                    setState(() {
                      selectedAssignedPerson = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reminderDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Days Before',
                    suffixText: 'day(s)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final int days = int.tryParse(value?.trim() ?? '') ?? -1;

                    if (days < 0) {
                      return 'Enter valid reminder days';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _TimePickerBox(
                  label: 'Reminder Time',
                  value: _formatTime(selectedReminderTime),
                  icon: Icons.notifications_active_rounded,
                  onTap: _pickReminderTime,
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorMessageBox(
                    message: controller.errorMessage!,
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: widget.isEdit ? 'Update Credit Card' : 'Save Credit Card',
                  icon: widget.isEdit
                      ? Icons.check_rounded
                      : Icons.save_rounded,
                  isLoading: controller.isSubmitting,
                  onPressed: controller.isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Cancel',
                  type: AppButtonType.outline,
                  onPressed: controller.isSubmitting
                      ? null
                      : () => Navigator.pop(context),
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
    required this.cardColor,
  });

  final bool isEdit;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.credit_card_rounded,
              color: cardColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update credit card balance and reminder details'
                  : 'Add card details using only last four digits',
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

class _SecurityNoticeCard extends StatelessWidget {
  const _SecurityNoticeCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'For safety, never enter full card number or CVV. Only last four digits are saved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePickerBox extends StatelessWidget {
  const _TimePickerBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
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
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> safeItems = items.isEmpty ? ['Select'] : items;
    final String safeValue = safeItems.contains(value) ? value : safeItems.first;

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ).copyWith(
        labelText: label,
      ),
      items: safeItems.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty || value == 'Select') {
          return 'Select $label';
        }

        return null;
      },
      onChanged: (String? value) {
        if (value == null) return;

        onChanged(value);
      },
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