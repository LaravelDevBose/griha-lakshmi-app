import 'reminder_model.dart';

class ReminderSummaryModel {
  const ReminderSummaryModel({
    required this.totalReminders,
    required this.todayReminders,
    required this.upcomingReminders,
    required this.completedReminders,
    required this.snoozedReminders,
  });

  final int totalReminders;
  final int todayReminders;
  final int upcomingReminders;
  final int completedReminders;
  final int snoozedReminders;

  factory ReminderSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReminderSummaryModel(
      totalReminders: int.tryParse(json['total_reminders'].toString()) ?? 0,
      todayReminders: int.tryParse(json['today_reminders'].toString()) ?? 0,
      upcomingReminders:
          int.tryParse(json['upcoming_reminders'].toString()) ?? 0,
      completedReminders:
          int.tryParse(json['completed_reminders'].toString()) ?? 0,
      snoozedReminders:
          int.tryParse(json['snoozed_reminders'].toString()) ?? 0,
    );
  }
}

class ReminderPaginationModel {
  const ReminderPaginationModel({
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

  factory ReminderPaginationModel.fromJson(Map<String, dynamic> json) {
    return ReminderPaginationModel(
      currentPage: int.tryParse(json['current_page'].toString()) ?? 1,
      perPage: int.tryParse(json['per_page'].toString()) ?? 10,
      total: int.tryParse(json['total'].toString()) ?? 0,
      lastPage: int.tryParse(json['last_page'].toString()) ?? 1,
    );
  }
}

class ReminderResponseModel {
  const ReminderResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    required this.summary,
    required this.pagination,
    required this.reminders,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final ReminderSummaryModel summary;
  final ReminderPaginationModel pagination;
  final List<ReminderModel> reminders;

  factory ReminderResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final List<dynamic> reminderList = data['reminders'] ?? [];

    return ReminderResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      summary: ReminderSummaryModel.fromJson(
        Map<String, dynamic>.from(data['summary'] ?? <String, dynamic>{}),
      ),
      pagination: ReminderPaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination'] ?? <String, dynamic>{}),
      ),
      reminders: reminderList.map((dynamic item) {
        return ReminderModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }
}