import 'bill_model.dart';

class BillSummaryModel {
  const BillSummaryModel({
    required this.totalBills,
    required this.upcomingBills,
    required this.paidBills,
    required this.overdueBills,
    required this.expectedTotal,
  });

  final int totalBills;
  final int upcomingBills;
  final int paidBills;
  final int overdueBills;
  final double expectedTotal;

  factory BillSummaryModel.fromJson(Map<String, dynamic> json) {
    return BillSummaryModel(
      totalBills: int.tryParse(json['total_bills'].toString()) ?? 0,
      upcomingBills: int.tryParse(json['upcoming_bills'].toString()) ?? 0,
      paidBills: int.tryParse(json['paid_bills'].toString()) ?? 0,
      overdueBills: int.tryParse(json['overdue_bills'].toString()) ?? 0,
      expectedTotal:
          double.tryParse(json['expected_total'].toString()) ?? 0,
    );
  }
}

class BillPaginationModel {
  const BillPaginationModel({
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

  factory BillPaginationModel.fromJson(Map<String, dynamic> json) {
    return BillPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class BillResponseModel {
  const BillResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.bills,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final BillSummaryModel summary;
  final BillPaginationModel pagination;
  final List<BillModel> bills;

  factory BillResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> billList = data['bills'] ?? [];

    return BillResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: BillSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: BillPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      bills: billList.map((dynamic item) {
        return BillModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}