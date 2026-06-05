import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../auth/auth_guard.dart';
import 'app_icon_box.dart';

class AppSidebarDrawer extends StatelessWidget {
  const AppSidebarDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const _DrawerHeader(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    routeName: AppRoutes.home,
                  ),
                  _DrawerItem(
                    icon: Icons.add_card_rounded,
                    title: 'Add Income',
                    routeName: AppRoutes.addIncome,
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Add Expense',
                    routeName: AppRoutes.addExpense,
                  ),
                  _DrawerItem(
                    icon: Icons.payments_rounded,
                    title: 'Bills',
                    routeName: AppRoutes.bills,
                  ),
                  _DrawerItem(
                    icon: Icons.savings_rounded,
                    title: 'Savings Goal',
                    routeName: AppRoutes.savingsGoal,
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports',
                    routeName: AppRoutes.reports,
                  ),
                  _DrawerItem(
                    icon: Icons.family_restroom_rounded,
                    title: 'Family Members',
                    routeName: AppRoutes.familySetup,
                  ),
                  _DrawerItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    routeName: AppRoutes.profile,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: _LogoutButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const AppIconBox(
            icon: Icons.account_balance_wallet_rounded,
            size: 52,
            iconSize: 26,
            backgroundColor: AppColors.white,
            iconColor: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.78),
                    fontSize: 12,
                    height: 1.3,
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

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = currentRoute == routeName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: AppColors.accent.withOpacity(0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.pop(context);

          if (currentRoute == routeName) return;

          Navigator.pushReplacementNamed(
            context,
            routeName,
          );
        },
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await AuthGuard.logout(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
            ),
            SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}