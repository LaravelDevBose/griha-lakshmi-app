import 'income_model.dart';

class IncomeSummaryModel {
  const IncomeSummaryModel({
    required this.totalIncome,
  });

  final double totalIncome;

  factory IncomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncomeSummaryModel(
      totalIncome: double.tryParse(json['total_income'].toString()) ?? 0,
    );
  }
}

class IncomePaginationModel {
  const IncomePaginationModel({
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

  factory IncomePaginationModel.fromJson(Map<String, dynamic> json) {
    return IncomePaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class IncomeResponseModel {
  const IncomeResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.incomes,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final IncomeSummaryModel summary;
  final IncomePaginationModel pagination;
  final List<IncomeModel> incomes;

  factory IncomeResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> incomeList = data['incomes'] ?? [];

    return IncomeResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: IncomeSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: IncomePaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      incomes: incomeList.map((dynamic item) {
        return IncomeModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}