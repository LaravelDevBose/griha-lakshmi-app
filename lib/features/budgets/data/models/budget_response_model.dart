import 'budget_model.dart';

class BudgetResponseModel {
  const BudgetResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.budget,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final BudgetModel? budget;

  factory BudgetResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic budgetJson = data['budget'];

    return BudgetResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      budget: budgetJson is Map<String, dynamic>
          ? BudgetModel.fromJson(budgetJson)
          : null,
    );
  }
}