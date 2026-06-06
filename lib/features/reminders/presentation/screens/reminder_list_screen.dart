import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/reminder_remote_datasource.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../controllers/reminder_controller.dart';
import 'add_edit_reminder_screen.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  late final ReminderController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = ReminderController(
      repository: ReminderRepository(
        remoteDataSource: ReminderRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getReminders();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final double currentPosition = scrollController.position.pixels;
    final double maxPosition = scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 240) {
      controller.loadMoreReminders();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year} • $formattedHour:$formattedMinute $period';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'snoozed':
        return Colors.blue;
      case 'today':
        return Colors.orange;
      case 'upcoming':
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _relatedIcon(String relatedType) {
    switch (relatedType) {
      case 'bill':
        return Icons.receipt_long_rounded;
      case 'loan':
        return Icons.account_balance_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'savings_goal':
        return Icons.savings_rounded;
      case 'budget':
        return Icons.pie_chart_rounded;
      case 'purchase_planner':
        return Icons.shopping_bag_rounded;
      case 'custom':
      default:
        return Icons.notifications_rounded;
    }
  }

  Future<void> _openAddReminder() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditReminderScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshReminders();
    }
  }

  Future<void> _openEditReminder(ReminderModel reminder) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditReminderScreen(
            controller: controller,
            reminder: reminder,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshReminders();
    }
  }

  Future<void> _handleRefresh() async {
    await controller.refreshReminders();

    if (!mounted) return;

    if (controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _completeReminder(ReminderModel reminder) async {
    Navigator.pop(context);

    final bool completed = await controller.completeReminder(reminder.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed
              ? controller.successMessage ?? 'Reminder completed'
              : controller.errorMessage ?? 'Unable to complete reminder',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _snoozeReminder(ReminderModel reminder) async {
    Navigator.pop(context);

    int selectedMinutes = 30;

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Snooze Reminder',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedMinutes,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Snooze Duration',
                        border: OutlineInputBorder(),
                      ),
                      items: controller.snoozeOptions.map((int minutes) {
                        return DropdownMenuItem<int>(
                          value: minutes,
                          child: Text(
                            minutes == 1440
                                ? 'Tomorrow'
                                : '$minutes minutes',
                          ),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        if (value == null) return;

                        setSheetState(() {
                          selectedMinutes = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Snooze',
                      icon: Icons.snooze_rounded,
                      onPressed: () => Navigator.pop(sheetContext, true),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Cancel',
                      type: AppButtonType.outline,
                      onPressed: () => Navigator.pop(sheetContext, false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final bool snoozed = await controller.snoozeReminder(
      id: reminder.id,
      snoozeMinutes: selectedMinutes,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          snoozed
              ? controller.successMessage ?? 'Reminder snoozed'
              : controller.errorMessage ?? 'Unable to snooze reminder',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openRelatedItem(ReminderModel reminder) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Open ${reminder.relatedType}: ${reminder.relatedTitle}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Later you can route based on reminder.relatedType:
    //
    // if (reminder.relatedType == 'bill') {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => const BillListScreen()));
    // }
    //
    // if (reminder.relatedType == 'loan') {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanListScreen()));
    // }
  }

  void _showReminderDetails(ReminderModel reminder) {
    final Color color = _statusColor(reminder.status);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _ReminderDetailsBottomSheet(
          reminder: reminder,
          color: color,
          relatedIcon: _relatedIcon(reminder.relatedType),
          formatDateTime: _formatDateTime,
          onEdit: () => _openEditReminder(reminder),
          onComplete: reminder.canComplete
              ? () => _completeReminder(reminder)
              : null,
          onSnooze:
              reminder.canSnooze ? () => _snoozeReminder(reminder) : null,
          onOpenRelated: () => _openRelatedItem(reminder),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.planner,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddReminder,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Reminder'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null &&
              controller.reminders.isEmpty) {
            return _ReminderErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getReminders,
            );
          }

          final List<ReminderModel> filteredReminders =
              controller.filteredReminders;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 96,
              ),
              children: [
                if (controller.isRefreshing) const _TopRefreshLoader(),
                _ReminderSummaryCard(
                  totalReminders: controller.totalReminders,
                  todayReminders: controller.todayReminders,
                  upcomingReminders: controller.upcomingReminders,
                  completedReminders: controller.completedReminders,
                  snoozedReminders: controller.snoozedReminders,
                ),
                const SizedBox(height: 16),
                _ReminderTabSection(
                  tabs: controller.tabs,
                  selectedTab: controller.selectedTab,
                  onChanged: controller.changeTab,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Reminders',
                  trailingText: '${filteredReminders.length} found',
                ),
                const SizedBox(height: 8),
                if (filteredReminders.isEmpty)
                  const _EmptyReminderState()
                else
                  ...filteredReminders.map(
                    (ReminderModel reminder) {
                      return _ReminderTile(
                        reminder: reminder,
                        color: _statusColor(reminder.status),
                        icon: _relatedIcon(reminder.relatedType),
                        formatDateTime: _formatDateTime,
                        onTap: () => _showReminderDetails(reminder),
                      );
                    },
                  ),
                if (controller.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                  ),
                if (!controller.hasMorePages && controller.reminders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more reminders',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopRefreshLoader extends StatelessWidget {
  const _TopRefreshLoader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Refreshing reminders...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderSummaryCard extends StatelessWidget {
  const _ReminderSummaryCard({
    required this.totalReminders,
    required this.todayReminders,
    required this.upcomingReminders,
    required this.completedReminders,
    required this.snoozedReminders,
  });

  final int totalReminders;
  final int todayReminders;
  final int upcomingReminders;
  final int completedReminders;
  final int snoozedReminders;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track tasks, payments, budget warnings, and assigned family reminders.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Today',
                  value: todayReminders.toString(),
                  icon: Icons.today_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Upcoming',
                  value: upcomingReminders.toString(),
                  icon: Icons.event_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Done',
                  value: completedReminders.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  const _SummaryMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTabSection extends StatelessWidget {
  const _ReminderTabSection({
    required this.tabs,
    required this.selectedTab,
    required this.onChanged,
  });

  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String tab = tabs[index];
          final bool isSelected = tab == selectedTab;

          return ChoiceChip(
            label: Text(tab),
            selected: isSelected,
            onSelected: (_) => onChanged(tab),
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
            selectedColor: theme.colorScheme.primary,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.44,
            ),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          );
        },
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.color,
    required this.icon,
    required this.formatDateTime,
    required this.onTap,
  });

  final ReminderModel reminder;
  final Color color;
  final IconData icon;
  final String Function(DateTime dateTime) formatDateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.09),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.018),
              blurRadius: 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reminder.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${reminder.assignedUser} • ${formatDateTime(reminder.dateTime)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _SmallBadge(
              text: reminder.status,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderDetailsBottomSheet extends StatelessWidget {
  const _ReminderDetailsBottomSheet({
    required this.reminder,
    required this.color,
    required this.relatedIcon,
    required this.formatDateTime,
    required this.onEdit,
    required this.onComplete,
    required this.onSnooze,
    required this.onOpenRelated,
  });

  final ReminderModel reminder;
  final Color color;
  final IconData relatedIcon;
  final String Function(DateTime dateTime) formatDateTime;
  final VoidCallback onEdit;
  final VoidCallback? onComplete;
  final VoidCallback? onSnooze;
  final VoidCallback onOpenRelated;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: color.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        relatedIcon,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      reminder.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reminder.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.60),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SmallBadge(
                text: reminder.status,
                color: color,
              ),
              const SizedBox(height: 10),
              _DetailRow(label: 'Related Type', value: reminder.relatedType),
              _DetailRow(label: 'Related Item', value: reminder.relatedTitle),
              _DetailRow(label: 'Assigned User', value: reminder.assignedUser),
              _DetailRow(
                label: 'Date & Time',
                value: formatDateTime(reminder.dateTime),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Edit',
                      icon: Icons.edit_rounded,
                      type: AppButtonType.outline,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Open Item',
                      icon: Icons.open_in_new_rounded,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onOpenRelated,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Snooze',
                      icon: Icons.snooze_rounded,
                      type: AppButtonType.secondary,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onSnooze,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Complete',
                      icon: Icons.check_circle_rounded,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onComplete,
                    ),
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

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
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
    this.trailingText,
  });

  final String title;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _EmptyReminderState extends StatelessWidget {
  const _EmptyReminderState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No reminder found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create reminders for payments, tasks, budgets, and family members.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderErrorState extends StatelessWidget {
  const _ReminderErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load reminders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Try Again',
                icon: Icons.refresh_rounded,
                isFullWidth: false,
                height: 46,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}