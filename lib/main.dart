import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
    debugPrintStack(stackTrace: details.stack);
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Firebase initialized successfully');
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const FamilyFundApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await NotificationService.initialize();
      debugPrint('Notification service initialized successfully');
    } catch (error, stackTrace) {
      debugPrint('Notification service initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  });
}