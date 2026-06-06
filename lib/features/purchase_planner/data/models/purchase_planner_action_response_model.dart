import 'purchase_item_model.dart';

class PurchasePlannerActionResponseModel {
  const PurchasePlannerActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.item,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final PurchaseItemModel? item;

  factory PurchasePlannerActionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic itemJson = data['item'];

    return PurchasePlannerActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      item: itemJson is Map<String, dynamic>
          ? PurchaseItemModel.fromJson(itemJson)
          : null,
    );
  }
}