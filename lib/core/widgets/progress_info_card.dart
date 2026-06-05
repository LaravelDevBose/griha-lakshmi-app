import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'amount_text.dart';
import 'app_card.dart';

class ProgressInfoCard extends StatelessWidget {
  const ProgressInfoCard({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    this.subtitle,
    this.progressColor = AppColors.primary,
  });

  final String title;
  final num currentAmount;
  final num targetAmount;
  final String? subtitle;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final double progress = targetAmount <= 0
        ? 0
        : (currentAmount / targetAmount).clamp(0, 1).toDouble();

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: AppColors.border,
              color: progressColor,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AmountText(
                amount: currentAmount,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              AmountText(
                amount: targetAmount,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                type: AmountTextType.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}