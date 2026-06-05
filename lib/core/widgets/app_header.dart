import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/theme.dart';
import 'app_icon_box.dart';
import 'notification_sheet.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Row(
        children: [
          // Left sidebar menu button
          Builder(
            builder: (context) {
              return _HeaderIconButton(
                icon: Icons.menu_rounded,
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),

          const Spacer(),

          // Middle app icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIconBox(
                icon: Icons.account_balance_wallet_rounded,
                size: 42,
                iconSize: 22,
                borderRadius: 14,
              ),
              const SizedBox(width: 10),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),

          const Spacer(),

          // Right notification button
          _NotificationButton(
            count: notificationCount,
            onTap: onNotificationTap ??
                () {
                  NotificationSheet.show(context);
                },
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onTap,
        ),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}