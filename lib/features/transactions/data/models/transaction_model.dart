enum TransactionType {
  income,
  expense,
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.member,
    required this.account,
    required this.date,
    required this.type,
    this.notes,
  });

  final int id;
  final String title;
  final double amount;
  final String category;
  final String member;
  final String account;
  final DateTime date;
  final TransactionType type;
  final String? notes;

  bool get isIncome => type == TransactionType.income;

  bool get isExpense => type == TransactionType.expense;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      category: json['category']?.toString() ?? '',
      member: json['member']?.toString() ?? '',
      account: json['account']?.toString() ?? '',
      date: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),
      type: _typeFromJson(json['type']?.toString()),
      notes: json['notes']?.toString(),
    );
  }

  static TransactionType _typeFromJson(String? value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }
}