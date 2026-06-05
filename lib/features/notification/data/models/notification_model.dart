import '../../domain/entities/app_notification.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final AppNotificationType type;
  final String icon;
  final bool isRead;
  final DateTime? createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: _parseType(json['type']),
      icon: json['icon']?.toString() ?? 'notification',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      icon: icon,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  static AppNotificationType _parseType(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'success':
        return AppNotificationType.success;
      case 'warning':
        return AppNotificationType.warning;
      case 'danger':
        return AppNotificationType.danger;
      case 'info':
      default:
        return AppNotificationType.info;
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}