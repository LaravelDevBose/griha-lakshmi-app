class AppNotification {
  const AppNotification({
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
}

enum AppNotificationType {
  success,
  warning,
  info,
  danger,
}