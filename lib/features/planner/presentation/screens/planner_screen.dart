import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_icon_box.dart';
import '../../../../core/widgets/app_scaffold.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  void _openRouteOrComingSoon({
    required BuildContext context,
    required String title,
    String? routeName,
  }) {
    if (routeName == null || routeName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title coming soon'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.planner,
      showQuickActionFab: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      body: ListView(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 96,
        ),
        children: [
          const _PlannerHeaderCard(),
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Planning Tools',
            subtitle: 'Plan future payments, goals, purchases, and budgets.',
          ),
          const SizedBox(height: 12),
          _PlannerCard(
            title: 'Purchase Planner',
            subtitle: 'Plan future family purchases and buying decisions.',
            icon: Icons.shopping_bag_rounded,
            color: AppColors.primary,
            onTap: () {
              _openRouteOrComingSoon(
                context: context,
                title: 'Purchase Planner',
                routeName: AppRoutes.purchasePlanner,
              );
            },
          ),
          const SizedBox(height: 10),
          _PlannerCard(
            title: 'Bills',
            subtitle: 'Track electricity, internet, gas, rent, and other bills.',
            icon: Icons.receipt_long_rounded,
            color: AppColors.info,
            onTap: () {
              _openRouteOrComingSoon(
                context: context,
                title: 'Bills',
                routeName: AppRoutes.bills,
              );
            },
          ),
          const SizedBox(height: 10),
          _PlannerCard(
            title: 'Loans',
            subtitle: 'Manage borrowed money, repayments, and due dates.',
            icon: Icons.account_balance_rounded,
            color: AppColors.warning,
            onTap: () {
              _openRouteOrComingSoon(
                context: context,
                title: 'Loans',
                routeName: AppRoutes.loans,
              );
            },
          ),
          const SizedBox(height: 10),
          _PlannerCard(
            title: 'Credit Cards',
            subtitle: 'Track card dues, billing cycles, and payments.',
            icon: Icons.credit_card_rounded,
            color: AppColors.danger,
            onTap: () {
              _openRouteOrComingSoon(
                context: context,
                title: 'Credit Cards',
                routeName: AppRoutes.creditCards,
              );
            },
          ),
          const SizedBox(height: 10),
          _PlannerCard(
            title: 'Savings Goals',
            subtitle: 'Set saving targets and monitor progress.',
            icon: Icons.savings_rounded,
            color: AppColors.success,
            onTap: () {
              _openRouteOrComingSoon(
                context: context,
                title: 'Savings Goals',
                routeName: AppRoutes.savingsGoal,
              );
            },
          ),
          const SizedBox(height: 10),
          _PlannerCard(
            title: 'Budgets',
            subtitle: 'Create monthly category limits and control spending.',
            icon: Icons.pie_chart_rounded,
            color: AppColors.primary,
            onTap: () {
              _openRouteOrComingSoon(
                context: context,
                title: 'Budgets',
                routeName: AppRoutes.budgets,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlannerHeaderCard extends StatelessWidget {
  const _PlannerHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AppIconBox(
            icon: Icons.event_note_rounded,
            size: 54,
            iconSize: 27,
            borderRadius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            iconColor: AppColors.primary,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planner',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Organize future family finance decisions in one place.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PlannerCard extends StatefulWidget {
  const _PlannerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_PlannerCard> createState() => _PlannerCardState();
}

class _PlannerCardState extends State<_PlannerCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 110),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) {
            setState(() {
              isPressed = true;
            });
          },
          onTapCancel: () {
            setState(() {
              isPressed = false;
            });
          },
          onTapUp: (_) {
            setState(() {
              isPressed = false;
            });
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.025),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AppIconBox(
                  icon: widget.icon,
                  size: 48,
                  iconSize: 23,
                  borderRadius: 16,
                  backgroundColor: widget.color.withValues(alpha: 0.11),
                  iconColor: widget.color,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}