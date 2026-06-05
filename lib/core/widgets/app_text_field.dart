import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onTap,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final String? label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      cursorColor: AppColors.primary,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
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
        suffixIcon: suffixIcon == null
            ? null
            : InkWell(
                onTap: onSuffixTap,
                borderRadius: BorderRadius.circular(24),
                child: Icon(
                  suffixIcon,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
      ),
    );

    if (label == null) {
      return field;
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
        field,
      ],
    );
  }
}