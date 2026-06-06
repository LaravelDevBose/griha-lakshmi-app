class PurchaseItemModel {
  const PurchaseItemModel({
    required this.id,
    required this.productName,
    required this.estimatedPrice,
    required this.category,
    required this.priority,
    required this.assignedTo,
    required this.neededByDate,
    required this.status,
    this.finalPrice,
    this.reminderDateTime,
    this.notes,
    this.productImage,
    this.purchaseLink,
  });

  final int id;
  final String productName;
  final double estimatedPrice;
  final double? finalPrice;
  final String category;
  final String priority;
  final String assignedTo;
  final DateTime neededByDate;
  final DateTime? reminderDateTime;
  final String status;
  final String? notes;
  final String? productImage;
  final String? purchaseLink;

  bool get isUrgent => priority.toLowerCase() == 'urgent';

  bool get isAssignedToMe => assignedTo.toLowerCase() == 'self';

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get canMarkPurchased => !isCompleted && !isCancelled;

  bool get canCancel => !isCompleted && !isCancelled;

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      productName: json['product_name']?.toString() ?? '',
      estimatedPrice:
          double.tryParse(json['estimated_price'].toString()) ?? 0,
      finalPrice: json['final_price'] == null
          ? null
          : double.tryParse(json['final_price'].toString()),
      category: json['category']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      neededByDate:
          DateTime.tryParse(json['needed_by_date'].toString()) ??
              DateTime.now(),
      reminderDateTime: json['reminder_date_time'] == null
          ? null
          : DateTime.tryParse(json['reminder_date_time'].toString()),
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      productImage: json['product_image']?.toString(),
      purchaseLink: json['purchase_link']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'product_name': productName,
      'estimated_price': estimatedPrice,
      'final_price': finalPrice,
      'category': category,
      'priority': priority,
      'assigned_to': assignedTo,
      'needed_by_date': neededByDate.toIso8601String(),
      'reminder_date_time': reminderDateTime?.toIso8601String(),
      'status': status,
      'notes': notes,
      'product_image': productImage,
      'purchase_link': purchaseLink,
    };
  }

  PurchaseItemModel copyWith({
    int? id,
    String? productName,
    double? estimatedPrice,
    double? finalPrice,
    String? category,
    String? priority,
    String? assignedTo,
    DateTime? neededByDate,
    DateTime? reminderDateTime,
    String? status,
    String? notes,
    String? productImage,
    String? purchaseLink,
  }) {
    return PurchaseItemModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      neededByDate: neededByDate ?? this.neededByDate,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      productImage: productImage ?? this.productImage,
      purchaseLink: purchaseLink ?? this.purchaseLink,
    );
  }
}