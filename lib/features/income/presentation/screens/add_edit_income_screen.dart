import 'package:flutter/material.dart';

import '../../../../core/api/api.dart';
import '../../data/datasources/income_remote_datasource.dart';
import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';
import '../controllers/income_controller.dart';

class AddEditIncomeScreen extends StatefulWidget {
  const AddEditIncomeScreen({
    this.controller,
    this.income,
    super.key,
  });

  final IncomeController? controller;
  final IncomeModel? income;

  bool get isEdit => income != null;

  @override
  State<AddEditIncomeScreen> createState() => _AddEditIncomeScreenState();
}

class _AddEditIncomeScreenState extends State<AddEditIncomeScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final IncomeController controller;
  late final bool shouldDisposeController;

  late final TextEditingController amountController;
  late final TextEditingController titleController;
  late final TextEditingController notesController;

  late String selectedCategory;
  late String selectedReceivedBy;
  late String selectedAccount;
  late DateTime selectedDate;
  late bool isRecurring;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = IncomeController(
        repository: IncomeRepository(
          remoteDataSource: IncomeRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final IncomeModel? income = widget.income;

    amountController = TextEditingController(
      text: income == null ? '' : income.amount.toStringAsFixed(0),
    );

    titleController = TextEditingController(
      text: income?.title ?? '',
    );

    notesController = TextEditingController(
      text: income?.notes ?? '',
    );

    selectedCategory = _safeInitialValue(
      value: income?.category,
      items: controller.categories,
    );

    selectedReceivedBy = _safeInitialValue(
      value: income?.receivedBy,
      items: controller.members,
    );

    selectedAccount = _safeInitialValue(
      value: income?.account,
      items: controller.accounts,
    );

    selectedDate = income?.date ?? DateTime.now();
    isRecurring = income?.isRecurring ?? false;
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    notesController.dispose();

    if (shouldDisposeController) {
      controller.dispose();
    }

    super.dispose();
  }

  String _safeInitialValue({
    required String? value,
    required List<String> items,
  }) {
    if (value != null && items.contains(value)) {
      return value;
    }

    if (items.isNotEmpty) {
      return items.first;
    }

    return '';
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

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      initialDate: selectedDate,
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final double amount = double.tryParse(amountController.text.trim()) ?? 0;

    final String? notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateIncome(
        id: widget.income!.id,
        title: titleController.text.trim(),
        amount: amount,
        category: selectedCategory,
        receivedBy: selectedReceivedBy,
        account: selectedAccount,
        date: selectedDate,
        isRecurring: isRecurring,
        notes: notes,
      );
    } else {
      success = await controller.storeIncome(
        title: titleController.text.trim(),
        amount: amount,
        category: selectedCategory,
        receivedBy: selectedReceivedBy,
        account: selectedAccount,
        date: selectedDate,
        isRecurring: isRecurring,
        notes: notes,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ??
                  (widget.isEdit
                      ? 'Income updated successfully'
                      : 'Income saved successfully')
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
    final ThemeData theme = Theme.of(context);
    const Color incomeColor = Colors.green;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Income' : 'Add Income'),
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _HeaderCard(
                  isEdit: widget.isEdit,
                  incomeColor: incomeColor,
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter title';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _DropdownField(
                  label: 'Category',
                  value: selectedCategory,
                  items: controller.categories,
                  onChanged: (String value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _DropdownField(
                  label: 'Received By',
                  value: selectedReceivedBy,
                  items: controller.members,
                  onChanged: (String value) {
                    setState(() {
                      selectedReceivedBy = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _DropdownField(
                  label: 'Account',
                  value: selectedAccount,
                  items: controller.accounts,
                  onChanged: (String value) {
                    setState(() {
                      selectedAccount = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate(selectedDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  child: SwitchListTile(
                    value: isRecurring,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recurring Income'),
                    subtitle: Text(
                      'Enable this for regular income like salary.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                    onChanged: (bool value) {
                      setState(() {
                        isRecurring = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes Optional',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),

                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorMessageBox(
                    message: controller.errorMessage!,
                  ),
                ],

                const SizedBox(height: 20),

                FilledButton(
                  onPressed: controller.isSubmitting ? null : _submit,
                  child: controller.isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : Text(widget.isEdit ? 'Update Income' : 'Save Income'),
                ),

                const SizedBox(height: 10),

                OutlinedButton(
                  onPressed: controller.isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.isEdit,
    required this.incomeColor,
  });

  final bool isEdit;
  final Color incomeColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: incomeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: incomeColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: incomeColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.savings_rounded,
              color: incomeColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update income information'
                  : 'Record a new family income',
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

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> safeItems = items.isEmpty ? ['Select'] : items;
    final String safeValue = safeItems.contains(value) ? value : safeItems.first;

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: safeItems.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty || value == 'Select') {
          return 'Select $label';
        }

        return null;
      },
      onChanged: (String? value) {
        if (value == null) return;

        onChanged(value);
      },
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