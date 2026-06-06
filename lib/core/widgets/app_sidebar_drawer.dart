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
      width: MediaQuery.sizeOf(context).width * 0.82,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: -24,
            end: 0,
          ),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(value, 0),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 0, 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(10, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const _ModernDrawerHeader(),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    children: const [
                      _DrawerSectionTitle(title: 'Main Menu'),
                      _DrawerItem(
                        icon: Icons.dashboard_rounded,
                        title: 'Dashboard',
                        routeName: AppRoutes.home,
                      ),
                      _DrawerItem(
                        icon: Icons.list_rounded,
                        title: 'Transactions',
                        routeName: AppRoutes.transactions,
                      ),
                      _DrawerItem(
                        icon: Icons.receipt_long_rounded,
                        title: 'Expenses',
                        routeName: AppRoutes.expense,
                      ),
                      _DrawerItem(
                        icon: Icons.add_card_rounded,
                        title: 'Incomes',
                        routeName: AppRoutes.incomes,
                      ),
                      _DrawerItem(
                        icon: Icons.receipt_long_rounded,
                        title: 'Bills',
                        routeName: AppRoutes.bills,
                      ),
                      _DrawerItem(
                        icon: Icons.account_balance_rounded,
                        title: 'Loans',
                        routeName: AppRoutes.loans,
                      ),
                      _DrawerItem(
                        icon: Icons.shopping_bag_rounded,
                        title: 'Purchase Planner',
                        routeName: AppRoutes.purchasePlanner,
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

                      SizedBox(height: 16),

                      _DrawerSectionTitle(title: 'Family'),
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

                const _DrawerFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernDrawerHeader extends StatelessWidget {
  const _ModernDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -32,
            right: -28,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Positioned(
            bottom: -42,
            left: -36,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Row(
            children: [
              const AppIconBox(
                icon: Icons.account_balance_wallet_rounded,
                size: 56,
                iconSize: 28,
                backgroundColor: AppColors.white,
                iconColor: AppColors.primary,
                borderRadius: 20,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      AppConstants.appTagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.75),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String routeName;

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = currentRoute == widget.routeName;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (_) {
              setState(() {
                _isPressed = true;
              });
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
              });
            },
            onTap: () {
              setState(() {
                _isPressed = false;
              });

              Navigator.pop(context);

              if (currentRoute == widget.routeName) return;

              Navigator.pushReplacementNamed(
                context,
                widget.routeName,
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1 : 0,
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          await AuthGuard.logout(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.14),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 22,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}