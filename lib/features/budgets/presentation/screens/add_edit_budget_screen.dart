import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/budget_remote_datasource.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../controllers/budget_controller.dart';

class AddEditBudgetScreen extends StatefulWidget {
  const AddEditBudgetScreen({
    this.controller,
    this.budget,
    super.key,
  });

  final BudgetController? controller;
  final BudgetModel? budget;

  bool get isEdit => budget != null;

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final BudgetController controller;
  late final bool shouldDisposeController;

  late final TextEditingController totalBudgetController;
  late final TextEditingController warningPercentageController;

  late DateTime selectedMonthDate;

  final List<_BudgetCategoryInput> categoryInputs = [];

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = BudgetController(
        repository: BudgetRepository(
          remoteDataSource: BudgetRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final BudgetModel? budget = widget.budget;

    totalBudgetController = TextEditingController(
      text: budget == null ? '' : budget.totalBudget.toStringAsFixed(0),
    );

    warningPercentageController = TextEditingController(
      text: budget?.warningPercentage.toString() ?? '80',
    );

    selectedMonthDate = _monthFromString(
      budget?.month,
    );

    if (budget != null && budget.categoryBudgets.isNotEmpty) {
      for (final BudgetCategoryModel category in budget.categoryBudgets) {
        categoryInputs.add(
          _BudgetCategoryInput.fromModel(category),
        );
      }
    } else {
      for (final String category in controller.defaultCategories.take(5)) {
        categoryInputs.add(
          _BudgetCategoryInput(
            id: DateTime.now().microsecondsSinceEpoch,
            categoryController: TextEditingController(text: category),
            budgetController: TextEditingController(),
            spentController: TextEditingController(text: '0'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    totalBudgetController.dispose();
    warningPercentageController.dispose();

    for (final _BudgetCategoryInput input in categoryInputs) {
      input.dispose();
    }

    if (shouldDisposeController) {
      controller.dispose();
    }

    super.dispose();
  }

  DateTime _monthFromString(String? month) {
    if (month == null || month.trim().isEmpty) {
      return DateTime(DateTime.now().year, DateTime.now().month);
    }

    final List<String> parts = month.split('-');

    if (parts.length != 2) {
      return DateTime(DateTime.now().year, DateTime.now().month);
    }

    final int year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final int monthNumber = int.tryParse(parts[1]) ?? DateTime.now().month;

    return DateTime(year, monthNumber);
  }

  String _monthToPayload(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');

    return '${date.year}-$month';
  }

  String _formatMonth(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickMonth() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: selectedMonthDate,
      helpText: 'Select budget month',
    );

    if (picked == null) return;

    setState(() {
      selectedMonthDate = DateTime(picked.year, picked.month);
    });
  }

  void _addCategoryRow() {
    setState(() {
      categoryInputs.add(
        _BudgetCategoryInput(
          id: DateTime.now().microsecondsSinceEpoch,
          categoryController: TextEditingController(),
          budgetController: TextEditingController(),
          spentController: TextEditingController(text: '0'),
        ),
      );
    });
  }

  void _removeCategoryRow(int index) {
    if (categoryInputs.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one category budget is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      categoryInputs[index].dispose();
      categoryInputs.removeAt(index);
    });
  }

  List<BudgetCategoryModel> _buildCategoryPayload() {
    return categoryInputs.map((_BudgetCategoryInput input) {
      return BudgetCategoryModel(
        id: input.id,
        categoryName: input.categoryController.text.trim(),
        budgetAmount:
            double.tryParse(input.budgetController.text.trim()) ?? 0,
        spentAmount: double.tryParse(input.spentController.text.trim()) ?? 0,
      );
    }).toList();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final double totalBudget =
        double.tryParse(totalBudgetController.text.trim()) ?? 0;

    final int warningPercentage =
        int.tryParse(warningPercentageController.text.trim()) ?? 80;

    final List<BudgetCategoryModel> categories = _buildCategoryPayload();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateBudget(
        id: widget.budget!.id,
        month: _monthToPayload(selectedMonthDate),
        totalBudget: totalBudget,
        warningPercentage: warningPercentage,
        categoryBudgets: categories,
      );
    } else {
      success = await controller.storeBudget(
        month: _monthToPayload(selectedMonthDate),
        totalBudget: totalBudget,
        warningPercentage: warningPercentage,
        categoryBudgets: categories,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ??
                  (widget.isEdit
                      ? 'Budget updated successfully'
                      : 'Budget saved successfully')
              : controller.errorMessage ?? 'Something went wrong',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color budgetColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Budget' : 'Add Budget',
      showDrawer: false,
      showFooter: false,
      showQuickActionFab: false,
      useCustomHeader: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 24,
              ),
              children: [
                _HeaderCard(
                  isEdit: widget.isEdit,
                  budgetColor: budgetColor,
                ),
                const SizedBox(height: 18),
                _PickerBox(
                  label: 'Month',
                  value: _formatMonth(selectedMonthDate),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickMonth,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: totalBudgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Budget',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid total budget';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: warningPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Warning Percentage',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final int percentage =
                        int.tryParse(value?.trim() ?? '') ?? 0;

                    if (percentage < 1 || percentage > 100) {
                      return 'Warning percentage must be between 1 and 100';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Category Budgets',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addCategoryRow,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(categoryInputs.length, (int index) {
                  return _CategoryBudgetInputCard(
                    index: index,
                    input: categoryInputs[index],
                    onRemove: () => _removeCategoryRow(index),
                  );
                }),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorMessageBox(
                    message: controller.errorMessage!,
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: widget.isEdit ? 'Update Budget' : 'Save Budget',
                  icon: widget.isEdit
                      ? Icons.check_rounded
                      : Icons.save_rounded,
                  isLoading: controller.isSubmitting,
                  onPressed: controller.isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Cancel',
                  type: AppButtonType.outline,
                  onPressed: controller.isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BudgetCategoryInput {
  _BudgetCategoryInput({
    required this.id,
    required this.categoryController,
    required this.budgetController,
    required this.spentController,
  });

  final int id;
  final TextEditingController categoryController;
  final TextEditingController budgetController;
  final TextEditingController spentController;

  factory _BudgetCategoryInput.fromModel(BudgetCategoryModel category) {
    return _BudgetCategoryInput(
      id: category.id,
      categoryController: TextEditingController(
        text: category.categoryName,
      ),
      budgetController: TextEditingController(
        text: category.budgetAmount.toStringAsFixed(0),
      ),
      spentController: TextEditingController(
        text: category.spentAmount.toStringAsFixed(0),
      ),
    );
  }

  void dispose() {
    categoryController.dispose();
    budgetController.dispose();
    spentController.dispose();
  }
}

class _CategoryBudgetInputCard extends StatelessWidget {
  const _CategoryBudgetInputCard({
    required this.index,
    required this.input,
    required this.onRemove,
  });

  final int index;
  final _BudgetCategoryInput input;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Category ${index + 1}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: input.categoryController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter category name';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: input.budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget Amount',
              prefixText: '৳ ',
              border: OutlineInputBorder(),
            ),
            validator: (String? value) {
              final double amount = double.tryParse(value?.trim() ?? '') ?? 0;

              if (amount <= 0) {
                return 'Enter valid budget amount';
              }

              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: input.spentController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Spent Amount',
              prefixText: '৳ ',
              border: OutlineInputBorder(),
            ),
            validator: (String? value) {
              final double amount = double.tryParse(value?.trim() ?? '') ?? -1;

              if (amount < 0) {
                return 'Enter valid spent amount';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.isEdit,
    required this.budgetColor,
  });

  final bool isEdit;
  final Color budgetColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: budgetColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: budgetColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: budgetColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.pie_chart_rounded,
              color: budgetColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update monthly budget and category limits'
                  : 'Create monthly budget and spending warnings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessageBox extends StatelessWidget {
  const _ErrorMessageBox({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}