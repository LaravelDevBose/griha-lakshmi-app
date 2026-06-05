import '../../domain/entities/recent_transaction.dart';

class RecentTransactionModel {
  const RecentTransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.icon,
  });

  final int id;
  final String title;
  final String subtitle;
  final num amount;
  final RecentTransactionType type;
  final String icon;

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amount: _parseNum(json['amount']),
      type: _parseType(json['type']),
      icon: json['icon']?.toString() ?? 'others',
    );
  }

  RecentTransaction toEntity() {
    return RecentTransaction(
      id: id,
      title: title,
      subtitle: subtitle,
      amount: amount,
      type: type,
      icon: icon,
    );
  }

  static RecentTransactionType _parseType(dynamic value) {
    final String type = value?.toString().toLowerCase() ?? '';

    if (type == 'income') {
      return RecentTransactionType.income;
    }

    return RecentTransactionType.expense;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}