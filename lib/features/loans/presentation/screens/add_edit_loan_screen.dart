import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/loan_remote_datasource.dart';
import '../../data/models/loan_model.dart';
import '../../data/repositories/loan_repository.dart';
import '../controllers/loan_controller.dart';

class AddEditLoanScreen extends StatefulWidget {
  const AddEditLoanScreen({
    this.controller,
    this.loan,
    super.key,
  });

  final LoanController? controller;
  final LoanModel? loan;

  bool get isEdit => loan != null;

  @override
  State<AddEditLoanScreen> createState() => _AddEditLoanScreenState();
}

class _AddEditLoanScreenState extends State<AddEditLoanScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final LoanController controller;
  late final bool shouldDisposeController;

  late final TextEditingController loanNameController;
  late final TextEditingController lenderNameController;
  late final TextEditingController originalAmountController;
  late final TextEditingController remainingBalanceController;
  late final TextEditingController installmentAmountController;
  late final TextEditingController interestRateController;
  late final TextEditingController dueDayController;
  late final TextEditingController reminderDaysController;

  late DateTime selectedStartDate;
  late DateTime selectedExpectedEndDate;
  late String selectedAssignedPerson;
  late TimeOfDay selectedReminderTime;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = LoanController(
        repository: LoanRepository(
          remoteDataSource: LoanRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final LoanModel? loan = widget.loan;

    loanNameController = TextEditingController(text: loan?.loanName ?? '');
    lenderNameController = TextEditingController(text: loan?.lenderName ?? '');

    originalAmountController = TextEditingController(
      text: loan == null ? '' : loan.originalAmount.toStringAsFixed(0),
    );

    remainingBalanceController = TextEditingController(
      text: loan == null ? '' : loan.remainingBalance.toStringAsFixed(0),
    );

    installmentAmountController = TextEditingController(
      text: loan == null ? '' : loan.installmentAmount.toStringAsFixed(0),
    );

    interestRateController = TextEditingController(
      text: loan?.interestRate == null ? '' : loan!.interestRate.toString(),
    );

    dueDayController = TextEditingController(
      text: loan?.dueDay.toString() ?? '1',
    );

    reminderDaysController = TextEditingController(
      text: loan?.reminderDaysBefore.toString() ?? '1',
    );

    selectedStartDate = loan?.startDate ?? DateTime.now();

    selectedExpectedEndDate = loan?.expectedEndDate ??
        DateTime(
          DateTime.now().year + 1,
          DateTime.now().month,
          DateTime.now().day,
        );

    selectedAssignedPerson = _safeInitialValue(
      value: loan?.assignedPerson,
      items: controller.members,
    );

    selectedReminderTime = _timeFromString(
      loan?.reminderTime ?? '09:00',
    );
  }

  @override
  void dispose() {
    loanNameController.dispose();
    lenderNameController.dispose();
    originalAmountController.dispose();
    remainingBalanceController.dispose();
    installmentAmountController.dispose();
    interestRateController.dispose();
    dueDayController.dispose();
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

  String _formatTime(TimeOfDay time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute $period';
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      initialDate: selectedStartDate,
    );

    if (picked == null) return;

    setState(() {
      selectedStartDate = picked;
    });
  }

  Future<void> _pickExpectedEndDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 15),
      initialDate: selectedExpectedEndDate,
    );

    if (picked == null) return;

    setState(() {
      selectedExpectedEndDate = picked;
    });
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

    final double originalAmount =
        double.tryParse(originalAmountController.text.trim()) ?? 0;

    final double remainingBalance =
        double.tryParse(remainingBalanceController.text.trim()) ?? 0;

    final double installmentAmount =
        double.tryParse(installmentAmountController.text.trim()) ?? 0;

    final double? interestRate = interestRateController.text.trim().isEmpty
        ? null
        : double.tryParse(interestRateController.text.trim());

    final int dueDay = int.tryParse(dueDayController.text.trim()) ?? 1;

    final int reminderDays =
        int.tryParse(reminderDaysController.text.trim()) ?? 1;

    bool success;

    if (widget.isEdit) {
      success = await controller.updateLoan(
        id: widget.loan!.id,
        loanName: loanNameController.text.trim(),
        lenderName: lenderNameController.text.trim(),
        originalAmount: originalAmount,
        remainingBalance: remainingBalance,
        installmentAmount: installmentAmount,
        interestRate: interestRate,
        startDate: selectedStartDate,
        dueDay: dueDay,
        expectedEndDate: selectedExpectedEndDate,
        assignedPerson: selectedAssignedPerson,
        reminderDaysBefore: reminderDays,
        reminderTime: _timeToString(selectedReminderTime),
      );
    } else {
      success = await controller.storeLoan(
        loanName: loanNameController.text.trim(),
        lenderName: lenderNameController.text.trim(),
        originalAmount: originalAmount,
        remainingBalance: remainingBalance,
        installmentAmount: installmentAmount,
        interestRate: interestRate,
        startDate: selectedStartDate,
        dueDay: dueDay,
        expectedEndDate: selectedExpectedEndDate,
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
                      ? 'Loan updated successfully'
                      : 'Loan saved successfully')
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
    final Color loanColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Loan' : 'Add Loan',
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
                  loanColor: loanColor,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: loanNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Loan Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter loan name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lenderNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Lender Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter lender name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: originalAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Original Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid original amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: remainingBalanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Remaining Balance',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? -1;

                    if (amount < 0) {
                      return 'Enter a valid remaining balance';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: installmentAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Installment Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid installment amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: interestRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate Optional',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerBox(
                  label: 'Start Date',
                  value: _formatDate(selectedStartDate),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dueDayController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Due Day',
                    hintText: 'Example: 10',
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
                _DatePickerBox(
                  label: 'Expected End Date',
                  value: _formatDate(selectedExpectedEndDate),
                  icon: Icons.event_available_rounded,
                  onTap: _pickExpectedEndDate,
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
                _DatePickerBox(
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
                  text: widget.isEdit ? 'Update Loan' : 'Save Loan',
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
    required this.loanColor,
  });

  final bool isEdit;
  final Color loanColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: loanColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: loanColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: loanColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.account_balance_rounded,
              color: loanColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update loan balance and reminder information'
                  : 'Add a loan to track repayment progress',
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

class _DatePickerBox extends StatelessWidget {
  const _DatePickerBox({
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