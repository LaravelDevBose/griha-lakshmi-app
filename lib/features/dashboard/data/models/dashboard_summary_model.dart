import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBalance,
    required this.totalSavings,
  });

  final num totalIncome;
  final num totalExpense;
  final num remainingBalance;
  final num totalSavings;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalIncome: _parseNum(json['total_income']),
      totalExpense: _parseNum(json['total_expense']),
      remainingBalance: _parseNum(json['remaining_balance']),
      totalSavings: _parseNum(json['total_savings']),
    );
  }

  DashboardSummary toEntity() {
    return DashboardSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      remainingBalance: remainingBalance,
      totalSavings: totalSavings,
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}