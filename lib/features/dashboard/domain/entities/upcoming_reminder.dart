class UpcomingReminder {
  const UpcomingReminder({
    required this.id,
    required this.title,
    required this.note,
    required this.amount,
    required this.dueDate,
    required this.type,
    required this.status,
    required this.icon,
  });

  final int id;
  final String title;
  final String note;
  final num amount;
  final DateTime? dueDate;
  final ReminderType type;
  final ReminderStatus status;
  final String icon;

  bool get isToday => status == ReminderStatus.today;
}

enum ReminderType {
  bill,
  purchase,
  other,
}

enum ReminderStatus {
  today,
  upcoming,
  overdue,
}