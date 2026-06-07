import 'account_model.dart';

class AccountSummaryModel {
  const AccountSummaryModel({
    required this.totalAccounts,
    required this.activeAccounts,
    required this.totalBalance,
  });

  final int totalAccounts;
  final int activeAccounts;
  final double totalBalance;

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      totalAccounts: int.tryParse(json['total_accounts'].toString()) ?? 0,
      activeAccounts: int.tryParse(json['active_accounts'].toString()) ?? 0,
      totalBalance: double.tryParse(json['total_balance'].toString()) ?? 0,
    );
  }
}

class AccountPaginationModel {
  const AccountPaginationModel({
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

  factory AccountPaginationModel.fromJson(Map<String, dynamic> json) {
    return AccountPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class AccountResponseModel {
  const AccountResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.accounts,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final AccountSummaryModel summary;
  final AccountPaginationModel pagination;
  final List<AccountModel> accounts;

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> accountList = data['accounts'] ?? [];

    return AccountResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: AccountSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: AccountPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      accounts: accountList.map((dynamic item) {
        return AccountModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}