class DashboardSummary {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBalance,
    required this.totalSavings,
  });

  final num totalIncome;
  final num totalExpense;
  final num remainingBalance;
  final num totalSavings;

  bool get isEmpty {
    return totalIncome == 0 &&
        totalExpense == 0 &&
        remainingBalance == 0 &&
        totalSavings == 0;
  }
}