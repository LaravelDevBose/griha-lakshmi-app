import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'amount_text.dart';
import 'app_card.dart';
import 'app_icon_box.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.subtitle,
    this.amountType = AmountTextType.normal,
    this.iconBackgroundColor,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final num amount;
  final IconData icon;
  final String? subtitle;
  final AmountTextType amountType;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(
            icon: icon,
            backgroundColor: iconBackgroundColor,
            iconColor: iconColor,
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          AmountText(
            amount: amount,
            type: amountType,
            fontSize: 22,
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}