import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/widgets.dart';

class WidgetPreviewScreen extends StatefulWidget {
  const WidgetPreviewScreen({super.key});

  @override
  State<WidgetPreviewScreen> createState() => _WidgetPreviewScreenState();
}

class _WidgetPreviewScreenState extends State<WidgetPreviewScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _categories = [
    'Grocery',
    'House Rent',
    'Electricity Bill',
    'Gas Bill',
    'WiFi Bill',
    'Medical',
    'Village Family Support',
    'Others',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Widget Preview',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Buttons',
              subtitle: 'Primary, secondary, outline, danger and loading buttons.',
            ),

            const SizedBox(height: 16),

            AppButton(
              text: 'Primary Button',
              icon: Icons.check_circle_outline_rounded,
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            AppButton(
              text: 'Secondary Button',
              type: AppButtonType.secondary,
              icon: Icons.wallet_rounded,
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            AppButton(
              text: 'Outline Button',
              type: AppButtonType.outline,
              icon: Icons.edit_outlined,
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            AppButton(
              text: 'Danger Button',
              type: AppButtonType.danger,
              icon: Icons.delete_outline_rounded,
              onPressed: () {},
            ),

            const SizedBox(height: 12),

            AppButton(
              text: 'Toggle Loading Button',
              isLoading: _isLoading,
              onPressed: () {
                setState(() {
                  _isLoading = !_isLoading;
                });
              },
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Input Fields',
              subtitle: 'Text field, amount field, dropdown and date picker.',
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _nameController,
              label: 'Expense Name',
              hintText: 'Enter expense name',
              prefixIcon: Icons.receipt_long_outlined,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _amountController,
              label: 'Amount',
              hintText: 'Enter amount',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),

            const SizedBox(height: 16),

            AppDropdown<String>(
              label: 'Category',
              hintText: 'Select category',
              value: _selectedCategory,
              items: _categories,
              itemLabel: (item) => item,
              prefixIcon: Icons.category_outlined,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 16),

            AppDateField(
              controller: _dateController,
              label: 'Date',
              hintText: 'Select date',
              initialDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Cards & Summary',
              subtitle: 'Finance summary cards for dashboard preview.',
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Income',
                    amount: 85000,
                    icon: Icons.trending_up_rounded,
                    amountType: AmountTextType.income,
                    iconBackgroundColor: AppColors.success.withValues(alpha: 0.10),
                    iconColor: AppColors.success,
                    subtitle: 'This month',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SummaryCard(
                    title: 'Expense',
                    amount: 52000,
                    icon: Icons.trending_down_rounded,
                    amountType: AmountTextType.expense,
                    iconBackgroundColor: AppColors.danger.withValues(alpha: 0.10),
                    iconColor: AppColors.danger,
                    subtitle: 'This month',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Balance',
                    amount: 33000,
                    icon: Icons.account_balance_wallet_rounded,
                    amountType: AmountTextType.normal,
                    subtitle: 'Remaining',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SummaryCard(
                    title: 'Savings',
                    amount: 12000,
                    icon: Icons.savings_outlined,
                    amountType: AmountTextType.warning,
                    iconBackgroundColor: AppColors.warning.withValues(alpha: 0.10),
                    iconColor: AppColors.warning,
                    subtitle: 'Saved',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Custom App Card',
                    subtitle: 'Use AppCard for reusable white card sections.',
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: const [
                      AppIconBox(
                        icon: Icons.family_restroom_rounded,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Family budget overview card with shared style.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Amount Text',
              subtitle: 'Different amount styles for income, expense and warning.',
            ),

            const SizedBox(height: 16),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AmountText(
                    amount: 25000,
                    type: AmountTextType.normal,
                  ),
                  SizedBox(height: 8),
                  AmountText(
                    amount: 85000,
                    type: AmountTextType.income,
                    showPlusMinus: true,
                  ),
                  SizedBox(height: 8),
                  AmountText(
                    amount: 12500,
                    type: AmountTextType.expense,
                    showPlusMinus: true,
                  ),
                  SizedBox(height: 8),
                  AmountText(
                    amount: 5000,
                    type: AmountTextType.warning,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Status Badges',
              subtitle: 'Use these for bills, payment status and reminders.',
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                StatusBadge(
                  text: 'Paid',
                  type: StatusBadgeType.success,
                ),
                StatusBadge(
                  text: 'Due Soon',
                  type: StatusBadgeType.warning,
                ),
                StatusBadge(
                  text: 'Unpaid',
                  type: StatusBadgeType.danger,
                ),
                StatusBadge(
                  text: 'Info',
                  type: StatusBadgeType.info,
                ),
                StatusBadge(
                  text: 'Pending',
                  type: StatusBadgeType.neutral,
                ),
              ],
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Category Chips',
              subtitle: 'Selectable category chips for expense and income forms.',
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                CategoryChip(
                  label: 'Grocery',
                  icon: Icons.shopping_basket_outlined,
                  isSelected: _selectedCategory == 'Grocery',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Grocery';
                    });
                  },
                ),
                CategoryChip(
                  label: 'Rent',
                  icon: Icons.home_outlined,
                  isSelected: _selectedCategory == 'House Rent',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'House Rent';
                    });
                  },
                ),
                CategoryChip(
                  label: 'Medical',
                  icon: Icons.medical_services_outlined,
                  isSelected: _selectedCategory == 'Medical',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'Medical';
                    });
                  },
                ),
                CategoryChip(
                  label: 'WiFi',
                  icon: Icons.wifi_rounded,
                  isSelected: _selectedCategory == 'WiFi Bill',
                  onTap: () {
                    setState(() {
                      _selectedCategory = 'WiFi Bill';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Progress Cards',
              subtitle: 'Useful for budget tracking and savings goals.',
            ),

            const SizedBox(height: 16),

            const ProgressInfoCard(
              title: 'Grocery Budget',
              subtitle: 'This month spending',
              currentAmount: 12000,
              targetAmount: 18000,
            ),

            const SizedBox(height: 12),

            const ProgressInfoCard(
              title: 'Emergency Fund',
              subtitle: 'Savings goal progress',
              currentAmount: 45000,
              targetAmount: 100000,
              progressColor: AppColors.warning,
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Transaction Tiles',
              subtitle: 'Use these for recent income and expense list.',
            ),

            const SizedBox(height: 16),

            const TransactionTile(
              title: 'Salary',
              subtitle: 'Income • Husband • 01 Jun 2026',
              amount: 65000,
              type: TransactionType.income,
              icon: Icons.work_outline_rounded,
            ),

            const SizedBox(height: 12),

            const TransactionTile(
              title: 'House Rent',
              subtitle: 'Expense • Joint • 05 Jun 2026',
              amount: 25000,
              type: TransactionType.expense,
              icon: Icons.home_outlined,
            ),

            const SizedBox(height: 12),

            const TransactionTile(
              title: 'Grocery',
              subtitle: 'Expense • Wife • 06 Jun 2026',
              amount: 4500,
              type: TransactionType.expense,
              icon: Icons.shopping_cart_outlined,
            ),

            const SizedBox(height: 32),

            SectionHeader(
              title: 'Dialog Preview',
              subtitle: 'Tap the button to preview confirmation dialog.',
              actionText: 'Show',
              onActionTap: () async {
                final bool? result = await ConfirmationDialog.show(
                  context,
                  title: 'Delete Expense?',
                  message:
                      'Are you sure you want to delete this expense record? This action cannot be undone.',
                  confirmText: 'Delete',
                  cancelText: 'Cancel',
                  isDanger: true,
                  icon: Icons.delete_outline_rounded,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result == true
                          ? 'Confirmed'
                          : 'Cancelled',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            AppButton(
              text: 'Show Confirmation Dialog',
              type: AppButtonType.outline,
              icon: Icons.info_outline_rounded,
              onPressed: () async {
                await ConfirmationDialog.show(
                  context,
                  title: 'Confirm Action',
                  message: 'Do you want to continue with this action?',
                  confirmText: 'Yes',
                  cancelText: 'No',
                  icon: Icons.help_outline_rounded,
                );
              },
            ),

            const SizedBox(height: 32),

            const SectionHeader(
              title: 'Empty, Loading & Error States',
              subtitle: 'Reusable full page states for API loading and empty data.',
            ),

            const SizedBox(height: 16),

            AppCard(
              child: SizedBox(
                height: 260,
                child: EmptyState(
                  title: 'No expenses yet',
                  message:
                      'Start adding your family expenses to see records here.',
                  icon: Icons.receipt_long_outlined,
                  buttonText: 'Add Expense',
                  onButtonPressed: () {},
                ),
              ),
            ),

            const SizedBox(height: 16),

            const AppCard(
              child: SizedBox(
                height: 180,
                child: LoadingView(
                  message: 'Loading family budget...',
                ),
              ),
            ),

            const SizedBox(height: 16),

            AppCard(
              child: SizedBox(
                height: 260,
                child: ErrorView(
                  title: 'Something went wrong',
                  message:
                      'We could not load your data. Please check your connection and try again.',
                  onRetry: () {},
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}