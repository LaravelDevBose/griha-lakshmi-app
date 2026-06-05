import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  danger,
  text,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52,
    this.borderRadius = 16,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    if (type == AppButtonType.text) {
      return TextButton(
        onPressed: isDisabled ? null : onPressed,
        child: _ButtonContent(
          text: text,
          icon: icon,
          isLoading: isLoading,
          color: AppColors.primary,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: type == AppButtonType.outline
          ? OutlinedButton(
              onPressed: isDisabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: _foregroundColor,
                side: BorderSide(
                  color: isDisabled ? AppColors.border : AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _ButtonContent(
                text: text,
                icon: icon,
                isLoading: isLoading,
                color: _foregroundColor,
              ),
            )
          : ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _backgroundColor,
                foregroundColor: _foregroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _ButtonContent(
                text: text,
                icon: icon,
                isLoading: isLoading,
                color: _foregroundColor,
              ),
            ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.primary;
      case AppButtonType.secondary:
        return AppColors.accent;
      case AppButtonType.danger:
        return AppColors.danger;
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case AppButtonType.secondary:
        return AppColors.primary;
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
      case AppButtonType.danger:
      case AppButtonType.primary:
        return AppColors.white;
    }
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.color,
  });

  final String text;
  final IconData? icon;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: color,
        ),
      );
    }

    if (icon == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}