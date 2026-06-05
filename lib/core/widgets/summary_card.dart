import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'amount_text.dart';
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
    final Widget child = Container(
      constraints: const BoxConstraints(
        minHeight: 104,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmall = constraints.maxWidth < 165;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBox(
                    icon: icon,
                    size: isSmall ? 38 : 42,
                    iconSize: isSmall ? 19 : 21,
                    borderRadius: 14,
                    backgroundColor:
                        iconBackgroundColor ?? AppColors.accent.withOpacity(0.45),
                    iconColor: iconColor ?? AppColors.primary,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AmountText(
                  amount: amount,
                  type: amountType,
                  compact: true,
                  fontSize: isSmall ? 20 : 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: child,
    );
  }
}