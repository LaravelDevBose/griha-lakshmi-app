import 'bill_model.dart';

class BillActionResponseModel {
  const BillActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.bill,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final BillModel? bill;

  factory BillActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic billJson = data['bill'];

    return BillActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      bill: billJson is Map<String, dynamic>
          ? BillModel.fromJson(billJson)
          : null,
    );
  }
}