import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../helpers/money_helper.dart';
import 'app_icon_box.dart';

class ExpenseProgressTile extends StatelessWidget {
  const ExpenseProgressTile({
    super.key,
    required this.title,
    required this.amount,
    required this.budget,
    required this.icon,
    this.progressColor = AppColors.primary,
  });

  final String title;
  final num amount;
  final num budget;
  final IconData icon;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final double progress = MoneyHelper.calculateProgress(
      current: amount,
      target: budget,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          AppIconBox(
            icon: icon,
            size: 40,
            iconSize: 20,
            borderRadius: 14,
            backgroundColor: progressColor.withValues(alpha: 0.10),
            iconColor: progressColor,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      MoneyHelper.formatCompactAmount(amount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                    color: progressColor,
                    backgroundColor: AppColors.border,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${MoneyHelper.formatPercentage(progress * 100)} of ${MoneyHelper.formatCompactAmount(budget)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}