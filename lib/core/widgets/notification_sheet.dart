import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/notification/domain/entities/app_notification.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';
import '../api/api.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_box.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_header.dart';
import '../../features/notification/data/datasources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';

class NotificationSheet extends StatefulWidget {
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
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  late final ApiClient _apiClient;
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();

    _controller = NotificationController(
      notificationRepository: NotificationRepositoryImpl(
        remoteDataSource: NotificationRemoteDataSource(
          apiClient: _apiClient,
        ),
      ),
    );

    _controller.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadNotifications();
    });
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const SizedBox(
        height: 240,
        child: LoadingView(
          message: 'Loading notifications...',
        ),
      );
    }

    if (_controller.isError) {
      return SizedBox(
        height: 280,
        child: ErrorView(
          title: 'Could not load notifications',
          message: _controller.failure?.firstErrorMessage ??
              'Something went wrong. Please try again.',
          onRetry: _controller.loadNotifications,
        ),
      );
    }

    if (_controller.isEmpty) {
      return const SizedBox(
        height: 260,
        child: EmptyState(
          title: 'No notifications',
          message: 'Your reminders and alerts will appear here.',
          icon: Icons.notifications_none_rounded,
        ),
      );
    }

    return Flexible(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _controller.loadNotifications,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _controller.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _NotificationItem(
              item: _controller.notifications[index],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.item,
  });

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      showShadow: false,
      backgroundColor: item.isRead
          ? AppColors.white
          : AppColors.accent.withOpacity(0.20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(
            icon: _icon,
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
      case AppNotificationType.success:
        return AppColors.success;
      case AppNotificationType.warning:
        return AppColors.warning;
      case AppNotificationType.danger:
        return AppColors.danger;
      case AppNotificationType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (item.icon) {
      case 'electricity':
        return Icons.electric_bolt_rounded;
      case 'income':
        return Icons.trending_up_rounded;
      case 'grocery':
        return Icons.shopping_basket_rounded;
      case 'bill':
        return Icons.payments_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}