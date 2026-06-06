import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme.dart';

enum AppFooterTab {
  home,
  transactions,
  planner,
  reports,
  more,
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
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FooterNavItem(
                icon: Icons.home_rounded,
                tab: AppFooterTab.home,
                currentTab: currentTab,
                routeName: AppRoutes.home,
              ),
              _FooterNavItem(
                icon: Icons.receipt_long_rounded,
                tab: AppFooterTab.transactions,
                currentTab: currentTab,
                routeName: AppRoutes.transactions,
              ),
              _FooterNavItem(
                icon: Icons.event_note_rounded,
                tab: AppFooterTab.planner,
                currentTab: currentTab,
                routeName: AppRoutes.planner,
              ),
              _FooterNavItem(
                icon: Icons.bar_chart_rounded,
                tab: AppFooterTab.reports,
                currentTab: currentTab,
                routeName: AppRoutes.reports,
              ),
              _FooterNavItem(
                icon: Icons.more_horiz_rounded,
                tab: AppFooterTab.more,
                currentTab: currentTab,
                routeName: AppRoutes.more,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterNavItem extends StatefulWidget {
  const _FooterNavItem({
    required this.icon,
    required this.tab,
    required this.currentTab,
    required this.routeName,
  });

  final IconData icon;
  final AppFooterTab tab;
  final AppFooterTab currentTab;
  final String routeName;

  @override
  State<_FooterNavItem> createState() => _FooterNavItemState();
}

class _FooterNavItemState extends State<_FooterNavItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  bool get _isSelected {
    return widget.tab == widget.currentTab;
  }

  void _goToRoute() {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == widget.routeName) return;

    Navigator.pushReplacementNamed(
      context,
      widget.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });

        _goToRoute();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: _isSelected ? 58 : 48,
          height: 46,
          decoration: BoxDecoration(
            color: _isSelected
                ? AppColors.accent
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                top: _isSelected ? 8 : 11,
                child: Icon(
                  widget.icon,
                  color: _isSelected
                      ? AppColors.primary
                      : AppColors.white.withValues(alpha: 0.66),
                  size: _isSelected ? 25 : 24,
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                bottom: _isSelected ? 6 : -10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isSelected ? 1 : 0,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
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