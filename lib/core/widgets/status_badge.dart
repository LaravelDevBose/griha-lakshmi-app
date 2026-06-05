import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum StatusBadgeType {
  success,
  warning,
  danger,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.text,
    this.type = StatusBadgeType.neutral,
  });

  final String text;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    final Color color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color get _color {
    switch (type) {
      case StatusBadgeType.success:
        return AppColors.success;
      case StatusBadgeType.warning:
        return AppColors.warning;
      case StatusBadgeType.danger:
        return AppColors.danger;
      case StatusBadgeType.info:
        return AppColors.info;
      case StatusBadgeType.neutral:
        return AppColors.textSecondary;
    }
  }
}