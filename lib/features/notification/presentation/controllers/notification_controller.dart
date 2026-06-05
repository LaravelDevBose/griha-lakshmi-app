import 'package:flutter/material.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

enum NotificationStateStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class NotificationController extends ChangeNotifier {
  NotificationController({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  final NotificationRepository _notificationRepository;

  NotificationStateStatus _status = NotificationStateStatus.initial;
  List<AppNotification> _notifications = [];
  Failure? _failure;

  NotificationStateStatus get status => _status;
  List<AppNotification> get notifications => _notifications;
  Failure? get failure => _failure;

  bool get isLoading => _status == NotificationStateStatus.loading;
  bool get isSuccess => _status == NotificationStateStatus.success;
  bool get isEmpty => _status == NotificationStateStatus.empty;
  bool get isError => _status == NotificationStateStatus.error;

  int get unreadCount {
    return _notifications.where((item) => !item.isRead).length;
  }

  Future<void> loadNotifications() async {
    _status = NotificationStateStatus.loading;
    _failure = null;
    notifyListeners();

    try {
      _notifications = await _notificationRepository.getNotifications();

      _status = _notifications.isEmpty
          ? NotificationStateStatus.empty
          : NotificationStateStatus.success;

      notifyListeners();
    } catch (error) {
      _failure = error is ApiException
          ? error.failure
          : ErrorHandler.handle(error);

      ErrorHandler.logError(_failure!);

      _status = NotificationStateStatus.error;
      notifyListeners();
    }
  }
}