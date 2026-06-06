import 'loan_model.dart';

class LoanActionResponseModel {
  const LoanActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.loan,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final LoanModel? loan;

  factory LoanActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic loanJson = data['loan'];

    return LoanActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      loan: loanJson is Map<String, dynamic>
          ? LoanModel.fromJson(loanJson)
          : null,
    );
  }
}