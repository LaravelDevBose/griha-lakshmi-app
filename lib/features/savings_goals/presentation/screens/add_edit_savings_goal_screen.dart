import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/savings_goal_remote_datasource.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/repositories/savings_goal_repository.dart';
import '../controllers/savings_goal_controller.dart';

class AddEditSavingsGoalScreen extends StatefulWidget {
  const AddEditSavingsGoalScreen({
    this.controller,
    this.savingsGoal,
    super.key,
  });

  final SavingsGoalController? controller;
  final SavingsGoalModel? savingsGoal;

  bool get isEdit => savingsGoal != null;

  @override
  State<AddEditSavingsGoalScreen> createState() =>
      _AddEditSavingsGoalScreenState();
}

class _AddEditSavingsGoalScreenState extends State<AddEditSavingsGoalScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final SavingsGoalController controller;
  late final bool shouldDisposeController;

  late final TextEditingController goalNameController;
  late final TextEditingController targetAmountController;
  late final TextEditingController currentAmountController;
  late final TextEditingController monthlyDepositTargetController;
  late final TextEditingController depositDueDayController;
  late final TextEditingController reminderDaysController;
  late final TextEditingController notesController;

  late String selectedGoalType;
  late String selectedAssignedPerson;
  late DateTime selectedTargetDate;
  late TimeOfDay selectedReminderTime;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = SavingsGoalController(
        repository: SavingsGoalRepository(
          remoteDataSource: SavingsGoalRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final SavingsGoalModel? goal = widget.savingsGoal;

    goalNameController = TextEditingController(
      text: goal?.goalName ?? '',
    );

    targetAmountController = TextEditingController(
      text: goal == null ? '' : goal.targetAmount.toStringAsFixed(0),
    );

    currentAmountController = TextEditingController(
      text: goal == null ? '' : goal.currentAmount.toStringAsFixed(0),
    );

    monthlyDepositTargetController = TextEditingController(
      text: goal == null ? '' : goal.monthlyDepositTarget.toStringAsFixed(0),
    );

    depositDueDayController = TextEditingController(
      text: goal?.depositDueDay.toString() ?? '1',
    );

    reminderDaysController = TextEditingController(
      text: goal?.reminderDaysBefore.toString() ?? '1',
    );

    notesController = TextEditingController(
      text: goal?.notes ?? '',
    );

    selectedGoalType = _safeInitialValue(
      value: goal?.goalType,
      items: controller.goalTypes,
    );

    selectedAssignedPerson = _safeInitialValue(
      value: goal?.assignedPerson,
      items: controller.members,
    );

    selectedTargetDate = goal?.targetDate ??
        DateTime(
          DateTime.now().year + 1,
          DateTime.now().month,
          DateTime.now().day,
        );

    selectedReminderTime = _timeFromString(
      goal?.reminderTime ?? '09:00',
    );
  }

  @override
  void dispose() {
    goalNameController.dispose();
    targetAmountController.dispose();
    currentAmountController.dispose();
    monthlyDepositTargetController.dispose();
    depositDueDayController.dispose();
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

  Future<void> _pickTargetDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
      initialDate: selectedTargetDate,
    );

    if (picked == null) return;

    setState(() {
      selectedTargetDate = picked;
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

    final double targetAmount =
        double.tryParse(targetAmountController.text.trim()) ?? 0;

    final double currentAmount =
        double.tryParse(currentAmountController.text.trim()) ?? 0;

    final double monthlyDepositTarget =
        double.tryParse(monthlyDepositTargetController.text.trim()) ?? 0;

    final int depositDueDay =
        int.tryParse(depositDueDayController.text.trim()) ?? 1;

    final int reminderDays =
        int.tryParse(reminderDaysController.text.trim()) ?? 1;

    final String? notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateSavingsGoal(
        id: widget.savingsGoal!.id,
        goalName: goalNameController.text.trim(),
        goalType: selectedGoalType,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        monthlyDepositTarget: monthlyDepositTarget,
        depositDueDay: depositDueDay,
        targetDate: selectedTargetDate,
        assignedPerson: selectedAssignedPerson,
        reminderDaysBefore: reminderDays,
        reminderTime: _timeToString(selectedReminderTime),
        notes: notes,
      );
    } else {
      success = await controller.storeSavingsGoal(
        goalName: goalNameController.text.trim(),
        goalType: selectedGoalType,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        monthlyDepositTarget: monthlyDepositTarget,
        depositDueDay: depositDueDay,
        targetDate: selectedTargetDate,
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
                      ? 'Savings goal updated successfully'
                      : 'Savings goal saved successfully')
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
    final Color goalColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Savings Goal' : 'Add Savings Goal',
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
                  goalColor: goalColor,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: goalNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter goal name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Goal Type',
                  value: selectedGoalType,
                  items: controller.goalTypes,
                  onChanged: (String value) {
                    setState(() {
                      selectedGoalType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid target amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: currentAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? -1;

                    if (amount < 0) {
                      return 'Enter a valid current amount';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: monthlyDepositTargetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Deposit Target',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid monthly deposit target';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: depositDueDayController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Deposit Due Day',
                    hintText: 'Example: 5',
                    suffixText: 'day',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final int day = int.tryParse(value?.trim() ?? '') ?? 0;

                    if (day < 1 || day > 28) {
                      return 'Deposit due day must be between 1 and 28';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DatePickerBox(
                  label: 'Target Date',
                  value: _formatDate(selectedTargetDate),
                  icon: Icons.event_available_rounded,
                  onTap: _pickTargetDate,
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
                  text: widget.isEdit
                      ? 'Update Savings Goal'
                      : 'Save Savings Goal',
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
    required this.goalColor,
  });

  final bool isEdit;
  final Color goalColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: goalColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: goalColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: goalColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.savings_rounded,
              color: goalColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update savings goal and reminder details'
                  : 'Create a savings goal and track deposits',
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