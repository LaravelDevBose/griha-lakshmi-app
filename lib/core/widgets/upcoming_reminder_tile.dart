import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../helpers/date_helper.dart';
import '../helpers/money_helper.dart';
import 'app_icon_box.dart';
import 'status_badge.dart';

class UpcomingReminderTile extends StatelessWidget {
  const UpcomingReminderTile({
    super.key,
    required this.title,
    required this.note,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.isToday,
    this.onTap,
  });

  final String title;
  final String note;
  final num amount;
  final DateTime? dueDate;
  final IconData icon;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isToday ? AppColors.warning : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.warning.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isToday
                ? AppColors.warning.withValues(alpha: 0.45)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            AppIconBox(
              icon: icon,
              size: 42,
              iconSize: 21,
              borderRadius: 14,
              backgroundColor: color.withValues(alpha: 0.12),
              iconColor: color,
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
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (isToday)
                        const StatusBadge(
                          text: 'Today',
                          type: StatusBadgeType.warning,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        MoneyHelper.formatCompactAmount(amount),
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dueDate == null
                            ? 'No date'
                            : DateHelper.formatSmartDate(dueDate!),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}