enum RecentTransactionType {
  income,
  expense,
}

class RecentTransaction {
  const RecentTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.icon,
  });

  final int id;
  final String title;
  final String subtitle;
  final num amount;
  final RecentTransactionType type;
  final String icon;
}