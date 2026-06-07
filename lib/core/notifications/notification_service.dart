import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_notification_service.dart';
import 'local_notification_service.dart';

class NotificationService {
  NotificationService._();

  static final LocalNotificationService _localNotificationService =
      LocalNotificationService.instance;

  static final FirebaseNotificationService _firebaseNotificationService =
      FirebaseNotificationService.instance;

  static bool _isInitialized = false;

  static Future<void> initialize({
    void Function(LocalNotificationPayload payload)? onLocalNotificationTap,
    void Function(RemoteMessage message)? onRemoteNotificationTap,
  }) async {
    if (_isInitialized) {
      return;
    }

    if (!kIsWeb) {
      tz.initializeTimeZones();
    }

    await _localNotificationService.initialize(
      onNotificationTap: onLocalNotificationTap,
    );

    await _localNotificationService.requestPermission();

    if (Firebase.apps.isNotEmpty) {
      await _firebaseNotificationService.initialize(
        onForegroundMessage: (RemoteMessage message) async {
          await _localNotificationService.showRemoteMessage(message);
        },
        onNotificationOpened: onRemoteNotificationTap,
      );
    } else {
      debugPrint(
        'Remote push notification skipped because Firebase is not initialized.',
      );
    }

    _isInitialized = true;
  }

  static Future<String?> getFcmToken() {
    if (Firebase.apps.isEmpty) {
      return Future<String?>.value(null);
    }

    return _firebaseNotificationService.getToken();
  }

  static Stream<String> onFcmTokenRefresh() {
    if (Firebase.apps.isEmpty) {
      return const Stream<String>.empty();
    }

    return _firebaseNotificationService.onTokenRefresh();
  }

  static Future<void> showReminderNotification({
    required int id,
    required String title,
    required String body,
    required String relatedType,
    required int relatedId,
  }) {
    return _localNotificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: LocalNotificationPayload(
        type: 'reminder',
        relatedType: relatedType,
        relatedId: relatedId.toString(),
      ),
    );
  }

  static Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required String relatedType,
    required int relatedId,
  }) {
    return _localNotificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDateTime: scheduledDateTime,
      payload: LocalNotificationPayload(
        type: 'reminder',
        relatedType: relatedType,
        relatedId: relatedId.toString(),
      ),
    );
  }

  static Future<void> showAssignedTaskNotification({
    required int id,
    required String title,
    required String assignedUser,
    required String relatedType,
    required int relatedId,
  }) {
    return _localNotificationService.showNotification(
      id: id,
      title: title,
      body: 'Assigned to $assignedUser',
      payload: LocalNotificationPayload(
        type: 'assigned_task',
        relatedType: relatedType,
        relatedId: relatedId.toString(),
      ),
    );
  }

  static Future<void> showPaymentDueNotification({
    required int id,
    required String title,
    required String message,
    required String relatedType,
    required int relatedId,
  }) {
    return _localNotificationService.showNotification(
      id: id,
      title: title,
      body: message,
      payload: LocalNotificationPayload(
        type: 'payment_due',
        relatedType: relatedType,
        relatedId: relatedId.toString(),
      ),
    );
  }

  static Future<void> showBudgetWarningNotification({
    required int id,
    required String categoryName,
    required double spentAmount,
    required double budgetAmount,
    required int budgetId,
  }) {
    return _localNotificationService.showNotification(
      id: id,
      title: 'Budget Warning',
      body:
          '$categoryName spending is high. Spent ৳${spentAmount.toStringAsFixed(0)} of ৳${budgetAmount.toStringAsFixed(0)}.',
      payload: LocalNotificationPayload(
        type: 'budget_warning',
        relatedType: 'budget',
        relatedId: budgetId.toString(),
      ),
    );
  }

  static Future<void> cancelNotification(int id) {
    return _localNotificationService.cancelNotification(id);
  }

  static Future<void> cancelAllNotifications() {
    return _localNotificationService.cancelAllNotifications();
  }
}