import 'income_model.dart';

class IncomeActionResponseModel {
  const IncomeActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.income,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final IncomeModel? income;

  factory IncomeActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic incomeJson = data['income'];

    return IncomeActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      income: incomeJson is Map<String, dynamic>
          ? IncomeModel.fromJson(incomeJson)
          : null,
    );
  }
}