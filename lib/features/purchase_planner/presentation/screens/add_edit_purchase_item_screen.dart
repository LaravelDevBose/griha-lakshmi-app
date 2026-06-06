import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/api/api.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image_preview_list.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/datasources/purchase_planner_remote_datasource.dart';
import '../../data/models/purchase_item_model.dart';
import '../../data/repositories/purchase_planner_repository.dart';
import '../controllers/purchase_planner_controller.dart';

class AddEditPurchaseItemScreen extends StatefulWidget {
  const AddEditPurchaseItemScreen({
    this.controller,
    this.item,
    super.key,
  });

  final PurchasePlannerController? controller;
  final PurchaseItemModel? item;

  bool get isEdit => item != null;

  @override
  State<AddEditPurchaseItemScreen> createState() =>
      _AddEditPurchaseItemScreenState();
}

class _AddEditPurchaseItemScreenState extends State<AddEditPurchaseItemScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();

  late final PurchasePlannerController controller;
  late final bool shouldDisposeController;

  late final TextEditingController productNameController;
  late final TextEditingController estimatedPriceController;
  late final TextEditingController purchaseLinkController;
  late final TextEditingController notesController;

  late String selectedCategory;
  late String selectedPriority;
  late String selectedAssignedTo;
  late DateTime neededByDate;
  DateTime? reminderDateTime;

  String? productImage;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
      shouldDisposeController = false;
    } else {
      controller = PurchasePlannerController(
        repository: PurchasePlannerRepository(
          remoteDataSource: PurchasePlannerRemoteDataSource(
            apiClient: ApiClient(),
          ),
        ),
      );
      shouldDisposeController = true;
    }

    final PurchaseItemModel? item = widget.item;

    productNameController = TextEditingController(
      text: item?.productName ?? '',
    );

    estimatedPriceController = TextEditingController(
      text: item == null ? '' : item.estimatedPrice.toStringAsFixed(0),
    );

    purchaseLinkController = TextEditingController(
      text: item?.purchaseLink ?? '',
    );

    notesController = TextEditingController(
      text: item?.notes ?? '',
    );

    selectedCategory = _safeInitialValue(
      value: item?.category,
      items: controller.categories,
    );

    selectedPriority = _safeInitialValue(
      value: item?.priority,
      items: controller.priorities,
    );

    selectedAssignedTo = _safeInitialValue(
      value: item?.assignedTo,
      items: controller.members,
    );

    neededByDate = item?.neededByDate ?? DateTime.now();
    reminderDateTime = item?.reminderDateTime;
    productImage = item?.productImage;
  }

  @override
  void dispose() {
    productNameController.dispose();
    estimatedPriceController.dispose();
    purchaseLinkController.dispose();
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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select reminder date and time';

    final String date = _formatDate(dateTime);
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return '$date, $formattedHour:$formattedMinute $period';
  }

  Future<void> _pickNeededByDate() async {
    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: neededByDate,
    );

    if (picked == null) return;

    setState(() {
      neededByDate = picked;
    });
  }

  Future<void> _pickReminderDateTime() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: reminderDateTime ?? now,
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: reminderDateTime == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(reminderDateTime!),
    );

    if (pickedTime == null) return;

    setState(() {
      reminderDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickProductImageFromGallery() async {
    final XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );

    if (file == null) return;

    setState(() {
      productImage = file.path;
    });
  }

  Future<void> _captureProductImageFromCamera() async {
    final XFile? file = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
    );

    if (file == null) return;

    setState(() {
      productImage = file.path;
    });
  }

  void _removeProductImage(int index) {
    setState(() {
      productImage = null;
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
                    _pickProductImageFromGallery();
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: 'Capture from Camera',
                  icon: Icons.camera_alt_rounded,
                  type: AppButtonType.outline,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _captureProductImageFromCamera();
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

    final double estimatedPrice =
        double.tryParse(estimatedPriceController.text.trim()) ?? 0;

    final String? notes = notesController.text.trim().isEmpty
        ? null
        : notesController.text.trim();

    final String? purchaseLink = purchaseLinkController.text.trim().isEmpty
        ? null
        : purchaseLinkController.text.trim();

    bool success;

    if (widget.isEdit) {
      success = await controller.updateItem(
        id: widget.item!.id,
        productName: productNameController.text.trim(),
        estimatedPrice: estimatedPrice,
        category: selectedCategory,
        priority: selectedPriority,
        neededByDate: neededByDate,
        assignedTo: selectedAssignedTo,
        reminderDateTime: reminderDateTime,
        notes: notes,
        productImage: productImage,
        purchaseLink: purchaseLink,
        status: widget.item!.status,
        finalPrice: widget.item!.finalPrice,
      );
    } else {
      success = await controller.storeItem(
        productName: productNameController.text.trim(),
        estimatedPrice: estimatedPrice,
        category: selectedCategory,
        priority: selectedPriority,
        neededByDate: neededByDate,
        assignedTo: selectedAssignedTo,
        reminderDateTime: reminderDateTime,
        notes: notes,
        productImage: productImage,
        purchaseLink: purchaseLink,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? controller.successMessage ??
                  (widget.isEdit
                      ? 'Purchase item updated successfully'
                      : 'Purchase item saved successfully')
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
    final Color plannerColor = Theme.of(context).colorScheme.primary;

    return AppScaffold(
      title: widget.isEdit ? 'Edit Purchase Item' : 'Add Purchase Item',
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
                  plannerColor: plannerColor,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: productNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter product name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: estimatedPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Price',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final double amount =
                        double.tryParse(value?.trim() ?? '') ?? 0;

                    if (amount <= 0) {
                      return 'Enter a valid estimated price';
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
                  label: 'Priority',
                  value: selectedPriority,
                  items: controller.priorities,
                  onChanged: (String value) {
                    setState(() {
                      selectedPriority = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _DropdownField(
                  label: 'Assigned To',
                  value: selectedAssignedTo,
                  items: controller.members,
                  onChanged: (String value) {
                    setState(() {
                      selectedAssignedTo = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _DatePickerBox(
                  label: 'Needed By Date',
                  value: _formatDate(neededByDate),
                  icon: Icons.calendar_month_rounded,
                  onTap: _pickNeededByDate,
                ),
                const SizedBox(height: 12),
                _DatePickerBox(
                  label: 'Reminder Date & Time',
                  value: _formatDateTime(reminderDateTime),
                  icon: Icons.notifications_active_rounded,
                  onTap: _pickReminderDateTime,
                  trailing: reminderDateTime == null
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              reminderDateTime = null;
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                const SizedBox(height: 12),
                _ProductImageSection(
                  productImage: productImage,
                  onAddImage: _showImageSourceSheet,
                  onRemoveImage: _removeProductImage,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: purchaseLinkController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Link Optional',
                    hintText: 'https://example.com/product',
                    border: OutlineInputBorder(),
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
                AppButton(
                  text: widget.isEdit ? 'Update Item' : 'Save Item',
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.isEdit,
    required this.plannerColor,
  });

  final bool isEdit;
  final Color plannerColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: plannerColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: plannerColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: plannerColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEdit ? Icons.edit_rounded : Icons.shopping_bag_rounded,
              color: plannerColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit
                  ? 'Update purchase planning item'
                  : 'Plan a new family purchase item',
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

class _ProductImageSection extends StatelessWidget {
  const _ProductImageSection({
    required this.productImage,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  final String? productImage;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> images = productImage == null ||
            productImage!.trim().isEmpty
        ? <String>[]
        : <String>[productImage!];

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
                  'Product Image Optional',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAddImage,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: Text(images.isEmpty ? 'Add' : 'Change'),
              ),
            ],
          ),
          AppImagePreviewList(
            imagePaths: images,
            canRemove: true,
            onRemove: onRemoveImage,
            emptyText: 'No product image added yet.',
          ),
        ],
      ),
    );
  }
}

class _DatePickerBox extends StatelessWidget {
  const _DatePickerBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

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
                  color: value.startsWith('Select')
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.48)
                      : null,
                ),
              ),
            ),
            if (trailing != null) trailing!,
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