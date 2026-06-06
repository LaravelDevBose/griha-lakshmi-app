import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/bill_remote_datasource.dart';
import '../../data/models/bill_model.dart';
import '../../data/repositories/bill_repository.dart';
import '../controllers/bill_controller.dart';

class AddEditBillScreen extends StatefulWidget {
  const AddEditBillScreen({
    this.controller,
    this.bill,
    super.key,
  });

  final BillController? controller;
  final BillModel? bill;

  bool get isEdit => bill != null;

  @override
  State<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends State<AddEditBillScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final BillController controller;
  late final bool shouldDisposeController;

  late final TextEditingController billNameController;
  late final TextEditingController expectedAmountController;
  late final TextEditingController reminderDaysController;
  late final TextEditingController notesController;

  late String selectedBillType;
  late String selectedRepeatFrequency;
  late String selectedAssignedPerson;
  late DateTime selectedDueDate;
  late TimeOfDay selectedReminderTime;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = BillController(
        repository: BillRepository(
          remoteDataSource: BillRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final BillModel? bill = widget.bill;

    billNameController = TextEditingController(
      text: bill?.billName ?? '',
    );

    expectedAmountController = TextEditingController(
      text: bill == null ? '' : bill.expectedAmount.toStringAsFixed(0),
    );

    reminderDaysController = TextEditingController(
      text: bill?.reminderDaysBefore.toString() ?? '1',
    );

    notesController = TextEditingController(
      text: bill?.notes ?? '',
    );

    selectedBillType = _safeInitialValue(
      value: bill?.billType,
      items: controller.billTypes,
    );

    selectedRepeatFrequency = _safeInitialValue(
      value: bill?.repeatFrequency,
      items: controller.repeatFrequencies,
    );

    selectedAssignedPerson = _safeInitialValue(
      value: bill?.assignedPerson,
      items: controller.members,
    );

    selectedDueDate = bill?.dueDate ?? DateTime.now();

    selectedReminderTime = _timeFromString(
      bill?.reminderTime ?? '09:00',
    );
  }

  @override
  void dispose() {
    billNameController.dispose();
    expectedAmountController.dispose();
    reminderDaysController.dispose();
    notesController.dispose();

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

  Future<void> _pickDueDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: selectedDueDate,
    );

    if (picked == null) return;

    setState(() {
      selectedDueDate = picked;
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

    final double expectedAmount =
        double.tryParse(expectedAmountController.text.trim()) ?? 0;

    final int reminderDays =
        int.tryParse(reminderDaysController.text.trim()) ?? 1;

    final String? notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateBill(
        id: widget.bill!.id,
        billName: billNameController.text.trim(),
        billType: selectedBillType,
        expectedAmount: expectedAmount,
        dueDate: selectedDueDate,
        repeatFrequency: selectedRepeatFrequency,
        assignedPerson: selectedAssignedPerson,
        reminderDaysBefore: reminderDays,
        reminderTime: _timeToString(selectedReminderTime),
        status: widget.bill!.status,
        hasReminder: widget.bill!.hasReminder,
        paidAmount: widget.bill!.paidAmount,
        paymentAccount: widget.bill!.paymentAccount,
        notes: notes,
      );
    } else {
      success = await controller.storeBill(
        billName: billNameController.text.trim(),
        billType: selectedBillType,
        expectedAmount: expectedAmount,
        dueDate: selectedDueDate,
        repeatFrequency: selectedRepeatFrequency,
        assignedPerson: selectedAssignedPerson,
        reminderDaysBefore: reminderDays,
        reminderTime: _timeToString(selectedReminderTime),
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
                      ? 'Bill updated successfully'
                      : 'Bill saved successfully')
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
    final Color billColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Bill' : 'Add Bill',
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
                  billColor: billColor,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: billNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Bill Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter bill name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Bill Type',
                  value: selectedBillType,
                  items: controller.billTypes,
                  onChanged: (String value) {
                    setState(() {
                      selectedBillType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: expectedAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expected Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid expected amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DatePickerBox(
                  label: 'Due Date',
                  value: _formatDate(selectedDueDate),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDueDate,
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Repeat Frequency',
                  value: selectedRepeatFrequency,
                  items: controller.repeatFrequencies,
                  onChanged: (String value) {
                    setState(() {
                      selectedRepeatFrequency = value;
                    });
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
                _DatePickerBox(
                  label: 'Reminder Time',
                  value: _formatTime(selectedReminderTime),
                  icon: Icons.notifications_active_rounded,
                  onTap: _pickReminderTime,
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
                  text: widget.isEdit ? 'Update Bill' : 'Save Bill',
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
    required this.billColor,
  });

  final bool isEdit;
  final Color billColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: billColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: billColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: billColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.receipt_long_rounded,
              color: billColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update bill reminder and payment information'
                  : 'Create a new bill reminder for your family',
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