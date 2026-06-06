import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/reminder_remote_datasource.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../controllers/reminder_controller.dart';

class AddEditReminderScreen extends StatefulWidget {
  const AddEditReminderScreen({
    this.controller,
    this.reminder,
    super.key,
  });

  final ReminderController? controller;
  final ReminderModel? reminder;

  bool get isEdit => reminder != null;

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final ReminderController controller;
  late final bool shouldDisposeController;

  late final TextEditingController titleController;
  late final TextEditingController messageController;
  late final TextEditingController relatedIdController;
  late final TextEditingController relatedTitleController;

  late String selectedRelatedType;
  late String selectedAssignedUser;
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = ReminderController(
        repository: ReminderRepository(
          remoteDataSource: ReminderRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final ReminderModel? reminder = widget.reminder;

    titleController = TextEditingController(
      text: reminder?.title ?? '',
    );

    messageController = TextEditingController(
      text: reminder?.message ?? '',
    );

    relatedIdController = TextEditingController(
      text: reminder == null || reminder.relatedId == 0
          ? ''
          : reminder.relatedId.toString(),
    );

    relatedTitleController = TextEditingController(
      text: reminder?.relatedTitle ?? '',
    );

    selectedRelatedType = _safeInitialValue(
      value: reminder?.relatedType,
      items: controller.relatedTypes,
    );

    selectedAssignedUser = _safeInitialValue(
      value: reminder?.assignedUser,
      items: controller.members,
    );

    selectedDateTime = reminder?.dateTime ??
        DateTime.now().add(
          const Duration(hours: 1),
        );
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    relatedIdController.dispose();
    relatedTitleController.dispose();

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

    return items.isEmpty ? '' : items.first;
  }

  String _formatDate(DateTime dateTime) {
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

    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute $period';
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: selectedDateTime,
    );

    if (picked == null) return;

    setState(() {
      selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        selectedDateTime.hour,
        selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (picked == null) return;

    setState(() {
      selectedDateTime = DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _scheduleLocalReminder({
    required int reminderId,
    required String title,
    required String message,
    required DateTime dateTime,
    required String relatedType,
    required int relatedId,
  }) async {
    await NotificationService.scheduleReminderNotification(
      id: reminderId,
      title: title,
      body: message,
      scheduledDateTime: dateTime,
      relatedType: relatedType,
      relatedId: relatedId,
    );
  }

  Future<void> _showAssignedUserNotification({
    required int reminderId,
    required String title,
    required String assignedUser,
    required String relatedType,
    required int relatedId,
  }) async {
    if (assignedUser == 'Self') {
      return;
    }

    await NotificationService.showAssignedTaskNotification(
      id: reminderId + 100000,
      title: title,
      assignedUser: assignedUser,
      relatedType: relatedType,
      relatedId: relatedId,
    );
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final int relatedId = int.tryParse(relatedIdController.text.trim()) ?? 0;

    final String relatedTitle = relatedTitleController.text.trim().isEmpty
        ? selectedRelatedType
        : relatedTitleController.text.trim();

    final String title = titleController.text.trim();
    final String message = messageController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateReminder(
        id: widget.reminder!.id,
        title: title,
        message: message,
        relatedType: selectedRelatedType,
        relatedId: relatedId,
        relatedTitle: relatedTitle,
        dateTime: selectedDateTime,
        assignedUser: selectedAssignedUser,
        currentStatus: widget.reminder!.status,
      );
    } else {
      success = await controller.storeReminder(
        title: title,
        message: message,
        relatedType: selectedRelatedType,
        relatedId: relatedId,
        relatedTitle: relatedTitle,
        dateTime: selectedDateTime,
        assignedUser: selectedAssignedUser,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ??
                  (widget.isEdit
                      ? 'Reminder updated successfully'
                      : 'Reminder saved successfully')
              : controller.errorMessage ?? 'Something went wrong',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (!success) {
      return;
    }

    final int reminderId =
        widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _scheduleLocalReminder(
      reminderId: reminderId,
      title: title,
      message: message,
      dateTime: selectedDateTime,
      relatedType: selectedRelatedType,
      relatedId: relatedId,
    );

    await _showAssignedUserNotification(
      reminderId: reminderId,
      title: title,
      assignedUser: selectedAssignedUser,
      relatedType: selectedRelatedType,
      relatedId: relatedId,
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final Color reminderColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Reminder' : 'Add Reminder',
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
                  reminderColor: reminderColor,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter reminder title';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter reminder message';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Related Type',
                  value: selectedRelatedType,
                  items: controller.relatedTypes,
                  onChanged: (String value) {
                    setState(() {
                      selectedRelatedType = value;

                      if (value == 'custom') {
                        relatedIdController.clear();
                        relatedTitleController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: relatedTitleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Related Title Optional',
                    hintText: 'Example: Electricity Bill',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: relatedIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Related ID Optional',
                    hintText: 'Use 0 or blank for custom reminder',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                _PickerBox(
                  label: 'Reminder Date',
                  value: _formatDate(selectedDateTime),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                _PickerBox(
                  label: 'Reminder Time',
                  value: _formatTime(selectedDateTime),
                  icon: Icons.notifications_active_rounded,
                  onTap: _pickTime,
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Assigned User',
                  value: selectedAssignedUser,
                  items: controller.members,
                  onChanged: (String value) {
                    setState(() {
                      selectedAssignedUser = value;
                    });
                  },
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorMessageBox(message: controller.errorMessage!),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: widget.isEdit ? 'Update Reminder' : 'Save Reminder',
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
    required this.reminderColor,
  });

  final bool isEdit;
  final Color reminderColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: reminderColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: reminderColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: reminderColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.notifications_rounded,
              color: reminderColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update reminder details and assigned user'
                  : 'Create a reminder and assign it to a family member',
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

class _PickerBox extends StatelessWidget {
  const _PickerBox({
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