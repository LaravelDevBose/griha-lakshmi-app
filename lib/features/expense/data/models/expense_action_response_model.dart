import 'expense_model.dart';

class ExpenseActionResponseModel {
  const ExpenseActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.expense,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final ExpenseModel? expense;

  factory ExpenseActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic expenseJson = data['expense'];

    return ExpenseActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      expense: expenseJson is Map<String, dynamic>
          ? ExpenseModel.fromJson(expenseJson)
          : null,
    );
  }
}