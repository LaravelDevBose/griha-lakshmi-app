import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationPayload {
  const LocalNotificationPayload({
    required this.type,
    required this.relatedType,
    required this.relatedId,
  });

  final String type;
  final String relatedType;
  final String relatedId;

  factory LocalNotificationPayload.fromString(String payload) {
    final List<String> parts = payload.split('|');

    return LocalNotificationPayload(
      type: parts.isNotEmpty ? parts[0] : 'reminder',
      relatedType: parts.length > 1 ? parts[1] : '',
      relatedId: parts.length > 2 ? parts[2] : '',
    );
  }

  @override
  String toString() {
    return '$type|$relatedType|$relatedId';
  }
}

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'family_finance_reminders',
    'Family Finance Reminders',
    description: 'Reminder notifications for bills, tasks, budgets, and goals.',
    importance: Importance.high,
  );

  bool _isInitialized = false;

  Future<void> initialize({
    void Function(LocalNotificationPayload payload)? onNotificationTap,
  }) async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;

        if (payload == null || payload.trim().isEmpty) {
          return;
        }

        onNotificationTap?.call(
          LocalNotificationPayload.fromString(payload),
        );
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_androidChannel);

    _isInitialized = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb) {
      return;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    LocalNotificationPayload? payload,
  }) async {
    if (kIsWeb) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'family_finance_reminders',
      'Family Finance Reminders',
      channelDescription:
          'Reminder notifications for bills, tasks, budgets, and goals.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload?.toString(),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    LocalNotificationPayload? payload,
  }) async {
    if (kIsWeb) {
      return;
    }

    final DateTime now = DateTime.now();

    if (scheduledDateTime.isBefore(now)) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'family_finance_reminders',
      'Family Finance Reminders',
      channelDescription:
          'Reminder notifications for bills, tasks, budgets, and goals.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload?.toString(),
    );
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    final String title =
        notification?.title ?? message.data['title']?.toString() ?? 'Reminder';

    final String body =
        notification?.body ?? message.data['message']?.toString() ?? '';

    final LocalNotificationPayload payload = LocalNotificationPayload(
      type: 'reminder',
      relatedType: message.data['related_type']?.toString() ?? '',
      relatedId: message.data['related_id']?.toString() ?? '',
    );

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) {
      return;
    }

    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      return;
    }

    await _localNotifications.cancelAll();
  }
}