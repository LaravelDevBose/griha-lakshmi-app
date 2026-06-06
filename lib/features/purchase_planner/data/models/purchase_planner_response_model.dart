import 'purchase_item_model.dart';

class PurchasePlannerSummaryModel {
  const PurchasePlannerSummaryModel({
    required this.totalItems,
    required this.urgentItems,
    required this.completedItems,
    required this.estimatedTotal,
  });

  final int totalItems;
  final int urgentItems;
  final int completedItems;
  final double estimatedTotal;

  factory PurchasePlannerSummaryModel.fromJson(Map<String, dynamic> json) {
    return PurchasePlannerSummaryModel(
      totalItems: int.tryParse(json['total_items'].toString()) ?? 0,
      urgentItems: int.tryParse(json['urgent_items'].toString()) ?? 0,
      completedItems:
          int.tryParse(json['completed_items'].toString()) ?? 0,
      estimatedTotal:
          double.tryParse(json['estimated_total'].toString()) ?? 0,
    );
  }
}

class PurchasePlannerPaginationModel {
  const PurchasePlannerPaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  bool get hasMorePages => currentPage < lastPage;

  factory PurchasePlannerPaginationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PurchasePlannerPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class PurchasePlannerResponseModel {
  const PurchasePlannerResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.items,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final PurchasePlannerSummaryModel summary;
  final PurchasePlannerPaginationModel pagination;
  final List<PurchaseItemModel> items;

  factory PurchasePlannerResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> itemList = data['items'] ?? [];

    return PurchasePlannerResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: PurchasePlannerSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: PurchasePlannerPaginationModel.fromJson(
        Map<String, dynamic>.from(
          data['pagination'] ?? <String, dynamic>{},
        ),
      ),
      items: itemList.map((dynamic item) {
        return PurchaseItemModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}