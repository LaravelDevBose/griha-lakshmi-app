import '../../domain/entities/upcoming_reminder.dart';

class UpcomingReminderModel {
  const UpcomingReminderModel({
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

  factory UpcomingReminderModel.fromJson(Map<String, dynamic> json) {
    return UpcomingReminderModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      amount: _parseNum(json['amount']),
      dueDate: DateTime.tryParse(json['due_date']?.toString() ?? ''),
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      icon: json['icon']?.toString() ?? 'other',
    );
  }

  UpcomingReminder toEntity() {
    return UpcomingReminder(
      id: id,
      title: title,
      note: note,
      amount: amount,
      dueDate: dueDate,
      type: type,
      status: status,
      icon: icon,
    );
  }

  static ReminderType _parseType(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'bill':
        return ReminderType.bill;
      case 'purchase':
        return ReminderType.purchase;
      default:
        return ReminderType.other;
    }
  }

  static ReminderStatus _parseStatus(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'today':
        return ReminderStatus.today;
      case 'overdue':
        return ReminderStatus.overdue;
      default:
        return ReminderStatus.upcoming;
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}