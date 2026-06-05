import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'amount_text.dart';
import 'app_icon_box.dart';

enum TransactionType {
  income,
  expense,
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final num amount;
  final TransactionType type;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = type == TransactionType.income;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
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
              size: 46,
              iconSize: 22,
              backgroundColor: isIncome
                  ? AppColors.success.withValues(alpha: 0.10)
                  : AppColors.danger.withValues(alpha: 0.10),
              iconColor: isIncome ? AppColors.success : AppColors.danger,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            AmountText(
              amount: amount,
              type: isIncome ? AmountTextType.income : AmountTextType.expense,
              showPlusMinus: true,
              fontSize: 15,
            ),
          ],
        ),
      ),
    );
  }
}