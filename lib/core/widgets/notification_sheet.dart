import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_card.dart';
import 'app_icon_box.dart';
import 'empty_state.dart';
import 'section_header.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({
    super.key,
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return const NotificationSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_NotificationItemData> notifications = [
      const _NotificationItemData(
        title: 'Electricity bill due soon',
        message: 'Your electricity bill is due in 2 days.',
        icon: Icons.electric_bolt_rounded,
        type: _NotificationType.warning,
      ),
      const _NotificationItemData(
        title: 'Salary added',
        message: '৳65,000 salary income was added successfully.',
        icon: Icons.trending_up_rounded,
        type: _NotificationType.success,
      ),
      const _NotificationItemData(
        title: 'Budget alert',
        message: 'Grocery expense reached 67% of monthly budget.',
        icon: Icons.shopping_basket_rounded,
        type: _NotificationType.info,
      ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 20),

              SectionHeader(
                title: 'Notifications',
                subtitle: 'Family finance updates and reminders.',
                actionText: 'Close',
                onActionTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 16),

              if (notifications.isEmpty)
                const SizedBox(
                  height: 260,
                  child: EmptyState(
                    title: 'No notifications',
                    message: 'Your reminders and alerts will appear here.',
                    icon: Icons.notifications_none_rounded,
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _NotificationItem(
                        item: notifications[index],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.item,
  });

  final _NotificationItemData item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(
            icon: item.icon,
            size: 44,
            iconSize: 22,
            backgroundColor: _color.withOpacity(0.10),
            iconColor: _color,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (item.type) {
      case _NotificationType.success:
        return AppColors.success;
      case _NotificationType.warning:
        return AppColors.warning;
      case _NotificationType.info:
        return AppColors.info;
    }
  }
}

class _NotificationItemData {
  const _NotificationItemData({
    required this.title,
    required this.message,
    required this.icon,
    required this.type,
  });

  final String title;
  final String message;
  final IconData icon;
  final _NotificationType type;
}

enum _NotificationType {
  success,
  warning,
  info,
}