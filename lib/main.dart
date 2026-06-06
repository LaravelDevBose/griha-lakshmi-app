
import 'app/app.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'core/notifications/local_notification_service.dart';
// import 'core/notifications/notification_service.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // await NotificationService.initialize(
  //   onLocalNotificationTap: (LocalNotificationPayload payload) {
  //     // Later we can add global navigation here.
  //     // Example:
  //     // payload.type
  //     // payload.relatedType
  //     // payload.relatedId
  //   },
  //   onRemoteNotificationTap: (RemoteMessage message) {
  //     // Later we can add global navigation here.
  //     // Example:
  //     // message.data['related_type']
  //     // message.data['related_id']
  //   },
  // );

  runApp(const FamilyFundApp());
}