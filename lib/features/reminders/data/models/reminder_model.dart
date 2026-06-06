class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.title,
    required this.message,
    required this.relatedType,
    required this.relatedId,
    required this.relatedTitle,
    required this.dateTime,
    required this.assignedUser,
    required this.status,
  });

  final int id;
  final String title;
  final String message;
  final String relatedType;
  final int relatedId;
  final String relatedTitle;
  final DateTime dateTime;
  final String assignedUser;
  final String status;

  bool get isToday => status.toLowerCase() == 'today';

  bool get isUpcoming => status.toLowerCase() == 'upcoming';

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isSnoozed => status.toLowerCase() == 'snoozed';

  bool get canComplete => !isCompleted;

  bool get canSnooze => !isCompleted;

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      relatedType: json['related_type']?.toString() ?? 'custom',
      relatedId: int.tryParse(json['related_id'].toString()) ?? 0,
      relatedTitle: json['related_title']?.toString() ?? '',
      dateTime:
          DateTime.tryParse(json['date_time'].toString()) ?? DateTime.now(),
      assignedUser: json['assigned_user']?.toString() ?? '',
      status: json['status']?.toString() ?? 'upcoming',
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'title': title,
      'message': message,
      'related_type': relatedType,
      'related_id': relatedId,
      'related_title': relatedTitle,
      'date_time': dateTime.toIso8601String(),
      'assigned_user': assignedUser,
      'status': status,
    };
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    String? message,
    String? relatedType,
    int? relatedId,
    String? relatedTitle,
    DateTime? dateTime,
    String? assignedUser,
    String? status,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedType: relatedType ?? this.relatedType,
      relatedId: relatedId ?? this.relatedId,
      relatedTitle: relatedTitle ?? this.relatedTitle,
      dateTime: dateTime ?? this.dateTime,
      assignedUser: assignedUser ?? this.assignedUser,
      status: status ?? this.status,
    );
  }
}