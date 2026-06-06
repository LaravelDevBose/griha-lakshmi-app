import 'reminder_model.dart';

class ReminderActionResponseModel {
  const ReminderActionResponseModel({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.code,
    this.reminder,
  });

  final bool success;
  final String message;
  final int statusCode;
  final String? code;
  final ReminderModel? reminder;

  factory ReminderActionResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(json['data'] ?? <String, dynamic>{});

    final dynamic reminderJson = data['reminder'];

    return ReminderActionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      statusCode: int.tryParse(json['status_code'].toString()) ?? 200,
      code: json['code']?.toString(),
      reminder: reminderJson is Map<String, dynamic>
          ? ReminderModel.fromJson(reminderJson)
          : null,
    );
  }
}