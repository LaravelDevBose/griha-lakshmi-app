import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_text_field.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      readOnly: true,
      prefixIcon: Icons.calendar_month_outlined,
      suffixIcon: Icons.keyboard_arrow_down_rounded,
      onTap: () => _pickDate(context),
      onSuffixTap: () => _pickDate(context),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.white,
                  surface: AppColors.white,
                  onSurface: AppColors.textPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    controller.text = _formatDate(selectedDate);
    onDateSelected(selectedDate);
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();

    return '$day/$month/$year';
  }
}