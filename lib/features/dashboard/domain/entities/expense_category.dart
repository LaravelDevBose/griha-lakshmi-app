class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.amount,
    required this.budget,
    required this.icon,
  });

  final String name;
  final num amount;
  final num budget;
  final String icon;
}