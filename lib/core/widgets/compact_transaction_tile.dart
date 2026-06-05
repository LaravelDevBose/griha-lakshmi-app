import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'amount_text.dart';
import 'app_icon_box.dart';

enum CompactTransactionType {
  income,
  expense,
}

class CompactTransactionTile extends StatelessWidget {
  const CompactTransactionTile({
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
  final CompactTransactionType type;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = type == CompactTransactionType.income;
    final Color color = isIncome ? AppColors.success : AppColors.danger;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
              size: 38,
              iconSize: 19,
              borderRadius: 13,
              backgroundColor: color.withOpacity(0.10),
              iconColor: color,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            AmountText(
              amount: amount,
              type: isIncome ? AmountTextType.income : AmountTextType.expense,
              compact: true,
              showPlusMinus: true,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ],
        ),
      ),
    );
  }
}