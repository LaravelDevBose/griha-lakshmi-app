import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/theme.dart';
import '../../features/notification/data/datasources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';
import '../api/api.dart';
import 'notification_sheet.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader>
    with SingleTickerProviderStateMixin {
  late final ApiClient _apiClient;
  late final NotificationController _notificationController;
  late final AnimationController _badgeAnimationController;

  @override
  void initState() {
    super.initState();

    _apiClient = ApiClient();

    _notificationController = NotificationController(
      notificationRepository: NotificationRepositoryImpl(
        remoteDataSource: NotificationRemoteDataSource(
          apiClient: _apiClient,
        ),
      ),
    );

    _badgeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.85,
      upperBound: 1.08,
    );

    _notificationController.addListener(_onNotificationChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationController.loadNotifications();
    });
  }

  void _onNotificationChanged() {
    if (!mounted) return;

    if (_notificationController.unreadCount > 0) {
      _badgeAnimationController.forward(from: 0.85);
    }

    setState(() {});
  }

  @override
  void dispose() {
    _notificationController.removeListener(_onNotificationChanged);
    _notificationController.dispose();
    _badgeAnimationController.dispose();
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
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

          _HeaderBrand(),

          const Spacer(),

          _NotificationButton(
            count: _notificationController.unreadCount,
            animationController: _badgeAnimationController,
            onTap: () async {
              await NotificationSheet.show(context);

              if (!mounted) return;

              await _notificationController.loadNotifications();
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0.96,
        end: 1,
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            AppConstants.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
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
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    required this.animationController,
    required this.onTap,
  });

  final int count;
  final AnimationController animationController;
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
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animationController,
                curve: Curves.easeOutBack,
              ),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
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
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}