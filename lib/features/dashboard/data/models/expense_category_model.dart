import '../../domain/entities/expense_category.dart';

class ExpenseCategoryModel {
  const ExpenseCategoryModel({
    required this.name,
    required this.amount,
    required this.budget,
    required this.icon,
  });

  final String name;
  final num amount;
  final num budget;
  final String icon;

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      name: json['name']?.toString() ?? '',
      amount: _parseNum(json['amount']),
      budget: _parseNum(json['budget']),
      icon: json['icon']?.toString() ?? 'others',
    );
  }

  ExpenseCategory toEntity() {
    return ExpenseCategory(
      name: name,
      amount: amount,
      budget: budget,
      icon: icon,
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}