import 'credit_card_model.dart';

class CreditCardActionResponseModel {
  const CreditCardActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.creditCard,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final CreditCardModel? creditCard;

  factory CreditCardActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic cardJson = data['credit_card'];

    return CreditCardActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      creditCard: cardJson is Map<String, dynamic>
          ? CreditCardModel.fromJson(cardJson)
          : null,
    );
  }
}