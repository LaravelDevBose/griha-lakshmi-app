import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image_preview_list.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../controllers/expense_controller.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({
    this.controller,
    this.expense,
    super.key,
  });

  final ExpenseController? controller;
  final ExpenseModel? expense;

  bool get isEdit => expense != null;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();

  late final ExpenseController controller;
  late final bool shouldDisposeController;

  late final TextEditingController amountController;
  late final TextEditingController titleController;
  late final TextEditingController notesController;

  late String selectedCategory;
  late String selectedPaidBy;
  late String selectedPaymentAccount;
  late DateTime selectedDate;

  List<String> receiptImages = [];

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = ExpenseController(
        repository: ExpenseRepository(
          remoteDataSource: ExpenseRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final ExpenseModel? expense = widget.expense;

    amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(0),
    );

    titleController = TextEditingController(
      text: expense?.title ?? '',
    );

    notesController = TextEditingController(
      text: expense?.notes ?? '',
    );

    selectedCategory = _safeInitialValue(
      value: expense?.category,
      items: controller.categories,
    );

    selectedPaidBy = _safeInitialValue(
      value: expense?.paidBy,
      items: controller.members,
    );

    selectedPaymentAccount = _safeInitialValue(
      value: expense?.paymentAccount,
      items: controller.accounts,
    );

    selectedDate = expense?.date ?? DateTime.now();
    receiptImages = [...expense?.receiptImages ?? []];
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

  Future<void> _pickFromGallery() async {
    final List<XFile> files = await imagePicker.pickMultiImage(
      imageQuality: 82,
    );

    if (files.isEmpty) return;

    setState(() {
      receiptImages = [
        ...receiptImages,
        ...files.map((XFile file) => file.path),
      ];
    });
  }

  Future<void> _captureFromCamera() async {
    final XFile? file = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
    );

    if (file == null) return;

    setState(() {
      receiptImages = [
        ...receiptImages,
        file.path,
      ];
    });
  }

  void _removeReceiptImage(int index) {
    setState(() {
      receiptImages.removeAt(index);
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  text: 'Choose from Gallery',
                  icon: Icons.photo_library_rounded,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _pickFromGallery();
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Capture from Camera',
                  icon: Icons.camera_alt_rounded,
                  type: AppButtonType.outline,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _captureFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final double amount = double.tryParse(amountController.text.trim()) ?? 0;

    final String? notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateExpense(
        id: widget.expense!.id,
        title: titleController.text.trim(),
        amount: amount,
        category: selectedCategory,
        paidBy: selectedPaidBy,
        paymentAccount: selectedPaymentAccount,
        date: selectedDate,
        receiptImages: receiptImages,
        notes: notes,
      );
    } else {
      success = await controller.storeExpense(
        title: titleController.text.trim(),
        amount: amount,
        category: selectedCategory,
        paidBy: selectedPaidBy,
        paymentAccount: selectedPaymentAccount,
        date: selectedDate,
        receiptImages: receiptImages,
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
                      ? 'Expense updated successfully'
                      : 'Expense saved successfully')
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
    const Color expenseColor = Colors.red;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Expense' : 'Add Expense',
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
                  expenseColor: expenseColor,
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
                  label: 'Paid By',
                  value: selectedPaidBy,
                  items: controller.members,
                  onChanged: (String value) {
                    setState(() {
                      selectedPaidBy = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Payment Account',
                  value: selectedPaymentAccount,
                  items: controller.accounts,
                  onChanged: (String value) {
                    setState(() {
                      selectedPaymentAccount = value;
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_month_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ReceiptImageSection(
                  receiptImages: receiptImages,
                  onAddImage: _showImageSourceSheet,
                  onRemoveImage: _removeReceiptImage,
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
                AppButton(
                  text: widget.isEdit ? 'Update Expense' : 'Save Expense',
                  icon: widget.isEdit
                      ? Icons.check_rounded
                      : Icons.save_rounded,
                  type: AppButtonType.danger,
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.isEdit,
    required this.expenseColor,
  });

  final bool isEdit;
  final Color expenseColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: expenseColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: expenseColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: expenseColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.receipt_long_rounded,
              color: expenseColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update expense information'
                  : 'Record a new family expense',
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

class _ReceiptImageSection extends StatelessWidget {
  const _ReceiptImageSection({
    required this.receiptImages,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  final List<String> receiptImages;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Receipt Images Optional',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAddImage,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          AppImagePreviewList(
            imagePaths: receiptImages,
            canRemove: true,
            onRemove: onRemoveImage,
            emptyText: 'No receipt image added yet.',
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ).copyWith(
        labelText: label,
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