import 'loan_model.dart';

class LoanSummaryModel {
  const LoanSummaryModel({
    required this.totalLoans,
    required this.activeLoans,
    required this.completedLoans,
    required this.totalRemainingBalance,
    required this.monthlyInstallmentTotal,
  });

  final int totalLoans;
  final int activeLoans;
  final int completedLoans;
  final double totalRemainingBalance;
  final double monthlyInstallmentTotal;

  factory LoanSummaryModel.fromJson(Map<String, dynamic> json) {
    return LoanSummaryModel(
      totalLoans: int.tryParse(json['total_loans'].toString()) ?? 0,
      activeLoans: int.tryParse(json['active_loans'].toString()) ?? 0,
      completedLoans: int.tryParse(json['completed_loans'].toString()) ?? 0,
      totalRemainingBalance:
          double.tryParse(json['total_remaining_balance'].toString()) ?? 0,
      monthlyInstallmentTotal:
          double.tryParse(json['monthly_installment_total'].toString()) ?? 0,
    );
  }
}

class LoanPaginationModel {
  const LoanPaginationModel({
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

  factory LoanPaginationModel.fromJson(Map<String, dynamic> json) {
    return LoanPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class LoanResponseModel {
  const LoanResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.loans,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final LoanSummaryModel summary;
  final LoanPaginationModel pagination;
  final List<LoanModel> loans;

  factory LoanResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> loanList = data['loans'] ?? [];

    return LoanResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: LoanSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: LoanPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      loans: loanList.map((dynamic item) {
        return LoanModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}