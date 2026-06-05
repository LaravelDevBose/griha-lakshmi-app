import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppIconBox extends StatelessWidget {
  const AppIconBox({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 16,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? AppColors.primary,
      ),
    );
  }
}