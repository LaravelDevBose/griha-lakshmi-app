class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.paymentAccount,
    required this.date,
    this.receiptImage,
    this.notes,
  });

  final int id;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final String paymentAccount;
  final DateTime date;
  final String? receiptImage;
  final String? notes;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      category: json['category']?.toString() ?? '',
      paidBy: json['paid_by']?.toString() ?? '',
      paymentAccount: json['payment_account']?.toString() ?? '',
      date: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),
      receiptImage: json['receipt_image']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'paid_by': paidBy,
      'payment_account': paymentAccount,
      'date': date.toIso8601String(),
      'receipt_image': receiptImage,
      'notes': notes,
    };
  }

  ExpenseModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? paidBy,
    String? paymentAccount,
    DateTime? date,
    String? receiptImage,
    String? notes,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paidBy: paidBy ?? this.paidBy,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      date: date ?? this.date,
      receiptImage: receiptImage ?? this.receiptImage,
      notes: notes ?? this.notes,
    );
  }
}