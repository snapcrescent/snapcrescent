import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._privateConstructor() : super();

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final NotificationService instance =
      NotificationService._privateConstructor();

  static Future initialize() async {
    _isAndroidPermissionGranted();
    _requestPermissions();

    var androidInitialize =
        new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    await _flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static showNotification(String title,String message) async {
    await _flutterLocalNotificationsPlugin.show(
          888,
          title,
          message,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "Snap-Crescent",
              'MY FOREGROUND SERVICE',
              ongoing: false,
              playSound: false,
              enableVibration: false,
              onlyAlertOnce: true,
              importance:Importance.min,
              priority:Priority.min
            ),
          ),
        );
  }

  static clearNotifications() async{
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
    }
  }
}
