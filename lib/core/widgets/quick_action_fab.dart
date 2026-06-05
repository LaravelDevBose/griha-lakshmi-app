import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../features/income/presentation/screens/add_edit_income_screen.dart';
import 'app_icon_box.dart';

class QuickActionFab extends StatefulWidget {
  const QuickActionFab({
    this.onIncomeSaved,
    super.key,
  });

  final VoidCallback? onIncomeSaved;

  @override
  State<QuickActionFab> createState() => _QuickActionFabState();
}

class _QuickActionFabState extends State<QuickActionFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Safe animation controller: always 0.0 to 1.0
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openQuickActionSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _QuickActionSheet(
          onIncomeSaved: widget.onIncomeSaved,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        child: GestureDetector(
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

            _openQuickActionSheet();
          },
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionSheet extends StatelessWidget {
  const _QuickActionSheet({
    this.onIncomeSaved,
  });

  final VoidCallback? onIncomeSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Add',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your daily family finance items faster.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  const _QuickActionItem(
                    title: 'Expense',
                    subtitle: 'Daily cost',
                    icon: Icons.receipt_long_rounded,
                    routeName: AppRoutes.addExpense,
                    color: AppColors.danger,
                  ),
                  const _QuickActionItem(
                    title: 'Purchase',
                    subtitle: 'Buy later',
                    icon: Icons.shopping_bag_rounded,
                    routeName: AppRoutes.addPurchase,
                    color: AppColors.primary,
                  ),
                  const _QuickActionItem(
                    title: 'Reminder',
                    subtitle: 'Upcoming task',
                    icon: Icons.notifications_active_rounded,
                    routeName: AppRoutes.addReminder,
                    color: AppColors.warning,
                  ),
                  _QuickActionItem(
                    title: 'Income',
                    subtitle: 'Money received',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                    pageBuilder: (_) => const AddEditIncomeScreen(),
                    onCompleted: onIncomeSaved,
                  ),
                  const _QuickActionItem(
                    title: 'Bill',
                    subtitle: 'Need to pay',
                    icon: Icons.payments_rounded,
                    routeName: AppRoutes.bills,
                    color: AppColors.info,
                  ),
                  const _QuickActionItem(
                    title: 'Savings',
                    subtitle: 'Goal deposit',
                    icon: Icons.savings_rounded,
                    routeName: AppRoutes.savingsGoal,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.routeName,
    this.pageBuilder,
    this.onCompleted,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? routeName;
  final WidgetBuilder? pageBuilder;
  final Color color;
  final VoidCallback? onCompleted;

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _isPressed = false;

  Future<void> _goToPage() async {
    final NavigatorState navigator = Navigator.of(context);

    navigator.pop();

    if (widget.pageBuilder != null) {
      final bool? result = await navigator.push<bool>(
        MaterialPageRoute(
          builder: widget.pageBuilder!,
        ),
      );

      if (result == true) {
        widget.onCompleted?.call();
      }

      return;
    }

    final String? routeName = widget.routeName;

    if (routeName == null || routeName.isEmpty) {
      return;
    }

    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == routeName) return;

    await navigator.pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _goToPage,
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
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                AppIconBox(
                  icon: widget.icon,
                  size: 44,
                  iconSize: 22,
                  borderRadius: 16,
                  backgroundColor: widget.color.withValues(alpha: 0.11),
                  iconColor: widget.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}