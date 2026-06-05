import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme.dart';

enum AppFooterTab {
  home,
  expense,
  report,
  profile,
}

class AppFooterNav extends StatelessWidget {
  const AppFooterNav({
    super.key,
    required this.currentTab,
  });

  final AppFooterTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FooterItem(
                icon: Icons.home_rounded,
                tab: AppFooterTab.home,
                currentTab: currentTab,
                onTap: () {
                  _goToRoute(context, AppRoutes.home);
                },
              ),
              _FooterItem(
                icon: Icons.receipt_long_rounded,
                tab: AppFooterTab.expense,
                currentTab: currentTab,
                onTap: () {
                  _goToRoute(context, AppRoutes.addExpense);
                },
              ),
              _FooterItem(
                icon: Icons.bar_chart_rounded,
                tab: AppFooterTab.report,
                currentTab: currentTab,
                onTap: () {
                  _goToRoute(context, AppRoutes.reports);
                },
              ),
              _FooterItem(
                icon: Icons.person_rounded,
                tab: AppFooterTab.profile,
                currentTab: currentTab,
                onTap: () {
                  _goToRoute(context, AppRoutes.profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToRoute(BuildContext context, String routeName) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == routeName) return;

    Navigator.pushReplacementNamed(
      context,
      routeName,
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({
    required this.icon,
    required this.tab,
    required this.currentTab,
    required this.onTap,
  });

  final IconData icon;
  final AppFooterTab tab;
  final AppFooterTab currentTab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = tab == currentTab;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 54,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 25,
        ),
      ),
    );
  }
}