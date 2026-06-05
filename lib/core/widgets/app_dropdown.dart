import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
    required this.itemLabel,
    this.label,
    this.prefixIcon,
    this.validator,
  });

  final List<T> items;
  final T? value;
  final String hintText;
  final ValueChanged<T?> onChanged;
  final String Function(T item) itemLabel;
  final String? label;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final Widget dropdown = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      validator: validator,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(
                prefixIcon,
                color: AppColors.textSecondary,
                size: 22,
              ),
      ),
      dropdownColor: AppColors.white,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );

    if (label == null) {
      return dropdown;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        dropdown,
      ],
    );
  }
}