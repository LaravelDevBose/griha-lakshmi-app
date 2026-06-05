class IncomeModel {
  const IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.receivedBy,
    required this.account,
    required this.date,
    required this.isRecurring,
    this.notes,
  });

  final int id;
  final String title;
  final double amount;
  final String category;
  final String receivedBy;
  final String account;
  final DateTime date;
  final bool isRecurring;
  final String? notes;

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      category: json['category']?.toString() ?? '',
      receivedBy: json['received_by']?.toString() ?? '',
      account: json['account']?.toString() ?? '',
      date: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),
      isRecurring: json['is_recurring'] == true ||
          json['is_recurring'] == 1 ||
          json['is_recurring']?.toString() == '1',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'received_by': receivedBy,
      'account': account,
      'date': date.toIso8601String(),
      'is_recurring': isRecurring,
      'notes': notes,
    };
  }

  IncomeModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? receivedBy,
    String? account,
    DateTime? date,
    bool? isRecurring,
    String? notes,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      receivedBy: receivedBy ?? this.receivedBy,
      account: account ?? this.account,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      notes: notes ?? this.notes,
    );
  }
}