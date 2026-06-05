import 'transaction_model.dart';

class TransactionSummaryModel {
  const TransactionSummaryModel({
    required this.income,
    required this.expenses,
    required this.balance,
  });

  final double income;
  final double expenses;
  final double balance;

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    return TransactionSummaryModel(
      income: double.tryParse(json['income'].toString()) ?? 0,
      expenses: double.tryParse(json['expenses'].toString()) ?? 0,
      balance: double.tryParse(json['balance'].toString()) ?? 0,
    );
  }
}

class TransactionPaginationModel {
  const TransactionPaginationModel({
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

  factory TransactionPaginationModel.fromJson(Map<String, dynamic> json) {
    return TransactionPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class TransactionResponseModel {
  const TransactionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.transactions,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final TransactionSummaryModel summary;
  final TransactionPaginationModel pagination;
  final List<TransactionModel> transactions;

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> transactionList = data['transactions'] ?? [];

    return TransactionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: TransactionSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: TransactionPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      transactions: transactionList.map(
        (item) {
          return TransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          );
        },
      ).toList(),
    );
  }
}