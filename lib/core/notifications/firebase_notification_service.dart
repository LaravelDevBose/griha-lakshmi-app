import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase should already be initialized from main.dart.
  // Later you can save background notification data locally if needed.
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  Future<void> initialize({
    required Future<void> Function(RemoteMessage message) onForegroundMessage,
    void Function(RemoteMessage message)? onNotificationOpened,
  }) async {
    if (_isInitialized) {
      return;
    }

    await requestPermission();

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await onForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onNotificationOpened?.call(message);
    });

    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      onNotificationOpened?.call(initialMessage);
    }

    _isInitialized = true;
  }

  Future<void> requestPermission() async {
    if (kIsWeb) {
      return;
    }

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<String?> getToken() async {
    return _firebaseMessaging.getToken();
  }

  Stream<String> onTokenRefresh() {
    return _firebaseMessaging.onTokenRefresh;
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}