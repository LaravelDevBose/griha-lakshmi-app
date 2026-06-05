import '../../domain/entities/dashboard.dart';
import 'dashboard_summary_model.dart';
import 'expense_category_model.dart';
import 'recent_transaction_model.dart';

class DashboardModel {
  const DashboardModel({
    required this.month,
    required this.summary,
    required this.expenseCategories,
    required this.recentTransactions,
  });

  final String month;
  final DashboardSummaryModel summary;
  final List<ExpenseCategoryModel> expenseCategories;
  final List<RecentTransactionModel> recentTransactions;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid dashboard response data.');
    }

    return DashboardModel(
      month: data['month']?.toString() ?? '',
      summary: DashboardSummaryModel.fromJson(
        _asMap(data['summary']),
      ),
      expenseCategories: _parseExpenseCategories(
        data['expense_categories'],
      ),
      recentTransactions: _parseRecentTransactions(
        data['recent_transactions'],
      ),
    );
  }

  Dashboard toEntity() {
    return Dashboard(
      month: month,
      summary: summary.toEntity(),
      expenseCategories: expenseCategories
          .map((category) => category.toEntity())
          .toList(),
      recentTransactions: recentTransactions
          .map((transaction) => transaction.toEntity())
          .toList(),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return <String, dynamic>{};
  }

  static List<ExpenseCategoryModel> _parseExpenseCategories(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => ExpenseCategoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  static List<RecentTransactionModel> _parseRecentTransactions(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => RecentTransactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }
}