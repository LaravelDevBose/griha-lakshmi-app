import 'expense_model.dart';

class ExpenseSummaryModel {
  const ExpenseSummaryModel({
    required this.totalExpense,
  });

  final double totalExpense;

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel(
      totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0,
    );
  }
}

class ExpensePaginationModel {
  const ExpensePaginationModel({
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

  factory ExpensePaginationModel.fromJson(Map<String, dynamic> json) {
    return ExpensePaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class ExpenseResponseModel {
  const ExpenseResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.expenses,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final ExpenseSummaryModel summary;
  final ExpensePaginationModel pagination;
  final List<ExpenseModel> expenses;

  factory ExpenseResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> expenseList = data['expenses'] ?? [];

    return ExpenseResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: ExpenseSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: ExpensePaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      expenses: expenseList.map((dynamic item) {
        return ExpenseModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}