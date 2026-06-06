import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_footer_nav.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/purchase_planner_remote_datasource.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/repositories/purchase_planner_repository.dart';
import '../controllers/purchase_planner_controller.dart';
import 'add_edit_purchase_item_screen.dart';

class PurchasePlannerListScreen extends StatefulWidget {
  const PurchasePlannerListScreen({super.key});

  @override
  State<PurchasePlannerListScreen> createState() =>
      _PurchasePlannerListScreenState();
}

class _PurchasePlannerListScreenState extends State<PurchasePlannerListScreen> {
  late final PurchasePlannerController controller;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    controller = PurchasePlannerController(
      repository: PurchasePlannerRepository(
        remoteDataSource: PurchasePlannerRemoteDataSource(
          apiClient: ApiClient(),
        ),
      ),
    );

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    controller.getItems();
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
      controller.loadMoreItems();
    }
  }

  String _formatAmount(double amount) {
    return '৳${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';

    final String date = _formatDate(dateTime);
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '$date, $formattedHour:$formattedMinute $period';
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'assigned':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Future<void> _openAddItem() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditPurchaseItemScreen(
            controller: controller,
          );
        },
      ),
    );

    if (saved == true) {
      await controller.refreshItems();
    }
  }

  Future<void> _openEditItem(PurchaseItemModel item) async {
    Navigator.pop(context);

    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddEditPurchaseItemScreen(
            controller: controller,
            item: item,
          );
        },
      ),
    );

    if (updated == true) {
      await controller.refreshItems();
    }
  }

  Future<void> _assignItem(PurchaseItemModel item) async {
    Navigator.pop(context);

    String selectedMember = item.assignedTo;

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
                      'Assign Item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: controller.members.contains(selectedMember)
                          ? selectedMember
                          : controller.members.first,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Assigned To',
                        border: OutlineInputBorder(),
                      ),
                      items: controller.members.map((String member) {
                        return DropdownMenuItem<String>(
                          value: member,
                          child: Text(member),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value == null) return;

                        setSheetState(() {
                          selectedMember = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Assign',
                      icon: Icons.person_add_alt_1_rounded,
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

    final bool assigned = await controller.assignItem(
      id: item.id,
      assignedTo: selectedMember,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          assigned
              ? controller.successMessage ?? 'Item assigned successfully'
              : controller.errorMessage ?? 'Unable to assign item',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markPurchased(PurchaseItemModel item) async {
    Navigator.pop(context);

    final TextEditingController finalPriceController = TextEditingController(
      text: item.finalPrice?.toStringAsFixed(0) ??
          item.estimatedPrice.toStringAsFixed(0),
    );

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mark as Purchased',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.productName,
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(sheetContext)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.60),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: finalPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Final Price',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Confirm Purchased',
                  icon: Icons.check_circle_rounded,
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

    if (confirmed != true) {
      finalPriceController.dispose();
      return;
    }

    final double finalPrice =
        double.tryParse(finalPriceController.text.trim()) ?? 0;

    finalPriceController.dispose();

    if (finalPrice <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid final price'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bool completed = await controller.markPurchased(
      id: item.id,
      finalPrice: finalPrice,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed
              ? controller.successMessage ??
                  'Item marked as purchased. Expense creation can be linked next.'
              : controller.errorMessage ?? 'Unable to mark as purchased',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancelItem(PurchaseItemModel item) async {
    Navigator.pop(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Item?'),
          content: Text(
            'Are you sure you want to cancel "${item.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel Item'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final bool cancelled = await controller.cancelItem(item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cancelled
              ? controller.successMessage ?? 'Item cancelled successfully'
              : controller.errorMessage ?? 'Unable to cancel item',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteItem(PurchaseItemModel item) async {
    Navigator.pop(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: Text(
            'Are you sure you want to delete "${item.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final bool deleted = await controller.deleteItem(item.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? controller.successMessage ?? 'Item deleted successfully'
              : controller.errorMessage ?? 'Unable to delete item',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showItemDetails(PurchaseItemModel item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return _PurchaseItemDetailsBottomSheet(
          item: item,
          formatAmount: _formatAmount,
          formatDate: _formatDate,
          formatDateTime: _formatDateTime,
          priorityColor: _priorityColor(item.priority),
          statusColor: _statusColor(item.status),
          onEdit: () => _openEditItem(item),
          onAssign: () => _assignItem(item),
          onMarkPurchased: item.canMarkPurchased
              ? () => _markPurchased(item)
              : null,
          onCancel: item.canCancel ? () => _cancelItem(item) : null,
          onDelete: () => _deleteItem(item),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    await controller.refreshItems();

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useCustomHeader: true,
      showDrawer: true,
      showFooter: true,
      footerTab: AppFooterTab.planner,
      showQuickActionFab: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItem,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Purchase'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.errorMessage != null && controller.items.isEmpty) {
            return _PurchasePlannerErrorState(
              message: controller.errorMessage!,
              onRetry: controller.getItems,
            );
          }

          final List<PurchaseItemModel> filteredItems =
              controller.filteredItems;

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
                _PurchaseSummaryCard(
                  totalItems: controller.totalItems,
                  urgentItems: controller.urgentItems,
                  completedItems: controller.completedItems,
                  estimatedTotal: controller.estimatedTotal,
                  formatAmount: _formatAmount,
                ),
                const SizedBox(height: 16),
                _TabFilterSection(
                  tabs: controller.tabs,
                  selectedTab: controller.selectedTab,
                  onChanged: controller.changeTab,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  title: 'Purchase Items',
                  trailingText: '${filteredItems.length} found',
                ),
                const SizedBox(height: 8),
                if (filteredItems.isEmpty)
                  const _EmptyPurchasePlannerState()
                else
                  ...filteredItems.map(
                    (PurchaseItemModel item) {
                      return _PurchaseItemTile(
                        item: item,
                        formatAmount: _formatAmount,
                        formatDate: _formatDate,
                        priorityColor: _priorityColor(item.priority),
                        statusColor: _statusColor(item.status),
                        onTap: () => _showItemDetails(item),
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
                if (!controller.hasMorePages && controller.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'No more purchase items',
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
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
              'Refreshing purchase planner...',
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

class _PurchaseSummaryCard extends StatelessWidget {
  const _PurchaseSummaryCard({
    required this.totalItems,
    required this.urgentItems,
    required this.completedItems,
    required this.estimatedTotal,
    required this.formatAmount,
  });

  final int totalItems;
  final int urgentItems;
  final int completedItems;
  final double estimatedTotal;
  final String Function(double amount) formatAmount;

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
            'Purchase Planner',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plan future purchases, assign family members, and track completion.',
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
                  title: 'Items',
                  value: totalItems.toString(),
                  icon: Icons.shopping_bag_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Urgent',
                  value: urgentItems.toString(),
                  icon: Icons.priority_high_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMiniCard(
                  title: 'Done',
                  value: completedItems.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimated Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatAmount(estimatedTotal),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
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

class _TabFilterSection extends StatelessWidget {
  const _TabFilterSection({
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

class _PurchaseItemTile extends StatelessWidget {
  const _PurchaseItemTile({
    required this.item,
    required this.formatAmount,
    required this.formatDate,
    required this.priorityColor,
    required this.statusColor,
    required this.onTap,
  });

  final PurchaseItemModel item;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final Color priorityColor;
  final Color statusColor;
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
                color: priorityColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: priorityColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${item.category} • ${item.assignedTo} • Needed ${formatDate(item.neededByDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _SmallBadge(
                        text: item.priority,
                        color: priorityColor,
                      ),
                      const SizedBox(width: 6),
                      _SmallBadge(
                        text: item.status,
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatAmount(item.estimatedPrice),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ],
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

class _PurchaseItemDetailsBottomSheet extends StatelessWidget {
  const _PurchaseItemDetailsBottomSheet({
    required this.item,
    required this.formatAmount,
    required this.formatDate,
    required this.formatDateTime,
    required this.priorityColor,
    required this.statusColor,
    required this.onEdit,
    required this.onAssign,
    required this.onMarkPurchased,
    required this.onCancel,
    required this.onDelete,
  });

  final PurchaseItemModel item;
  final String Function(double amount) formatAmount;
  final String Function(DateTime date) formatDate;
  final String Function(DateTime? dateTime) formatDateTime;
  final Color priorityColor;
  final Color statusColor;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback? onMarkPurchased;
  final VoidCallback? onCancel;
  final VoidCallback onDelete;

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
                  color: priorityColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: priorityColor.withValues(alpha: 0.14),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: priorityColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.productName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatAmount(item.estimatedPrice),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.finalPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Final: ${formatAmount(item.finalPrice!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _SmallBadge(
                    text: item.priority,
                    color: priorityColor,
                  ),
                  const SizedBox(width: 8),
                  _SmallBadge(
                    text: item.status,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DetailRow(label: 'Category', value: item.category),
              _DetailRow(label: 'Assigned To', value: item.assignedTo),
              _DetailRow(label: 'Needed By', value: formatDate(item.neededByDate)),
              _DetailRow(
                label: 'Reminder',
                value: formatDateTime(item.reminderDateTime),
              ),
              if (item.purchaseLink != null &&
                  item.purchaseLink!.trim().isNotEmpty)
                _DetailRow(label: 'Purchase Link', value: item.purchaseLink!),
              if (item.notes != null && item.notes!.trim().isNotEmpty)
                _DetailRow(label: 'Notes', value: item.notes!),
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
                      text: 'Assign',
                      icon: Icons.person_add_alt_1_rounded,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onAssign,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (onMarkPurchased != null)
                AppButton(
                  text: 'Mark as Purchased',
                  icon: Icons.check_circle_rounded,
                  type: AppButtonType.secondary,
                  height: 48,
                  borderRadius: 14,
                  onPressed: onMarkPurchased,
                ),
              if (onMarkPurchased != null) const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      icon: Icons.cancel_rounded,
                      type: AppButtonType.outline,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      icon: Icons.delete_rounded,
                      type: AppButtonType.danger,
                      height: 48,
                      borderRadius: 14,
                      onPressed: onDelete,
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

class _EmptyPurchasePlannerState extends StatelessWidget {
  const _EmptyPurchasePlannerState();

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
            Icons.shopping_bag_rounded,
            size: 42,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            'No purchase item found',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first planned purchase to start tracking.',
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

class _PurchasePlannerErrorState extends StatelessWidget {
  const _PurchasePlannerErrorState({
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
                'Unable to load purchase planner',
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