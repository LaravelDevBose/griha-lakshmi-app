import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  bool _isInitialized = false;

  Future<void> initialize({
    required Future<void> Function(RemoteMessage message) onForegroundMessage,
    void Function(RemoteMessage message)? onNotificationOpened,
  }) async {
    if (_isInitialized) {
      return;
    }

    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    if (Firebase.apps.isEmpty) {
      debugPrint(
        'FirebaseNotificationService skipped because Firebase is not initialized.',
      );
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
    if (kIsWeb || Firebase.apps.isEmpty) {
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
    if (kIsWeb || Firebase.apps.isEmpty) {
      return null;
    }

    return _firebaseMessaging.getToken();
  }

  Stream<String> onTokenRefresh() {
    if (Firebase.apps.isEmpty) {
      return const Stream<String>.empty();
    }

    return _firebaseMessaging.onTokenRefresh;
  }

  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb || Firebase.apps.isEmpty) {
      return;
    }

    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb || Firebase.apps.isEmpty) {
      return;
    }

    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}