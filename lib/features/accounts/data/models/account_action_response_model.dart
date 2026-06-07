import 'account_model.dart';

class AccountActionResponseModel {
  const AccountActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.account,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final AccountModel? account;

  factory AccountActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic accountJson = data['account'];

    return AccountActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      account: accountJson is Map<String, dynamic>
          ? AccountModel.fromJson(accountJson)
          : null,
    );
  }
}