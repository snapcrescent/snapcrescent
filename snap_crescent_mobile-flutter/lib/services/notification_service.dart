import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:snap_crescent/utils/constants.dart';

class NotificationService {
  NotificationService._privateConstructor() : super();

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService._privateConstructor();

  Future initialize() async {
    await requestPermissions();

    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = new DarwinInitializationSettings();
    var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await _flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  showNotification(String title,String message, [String? channelName]) async {
    if(await isAndroidPermissionGranted()) {

      if(channelName == null) {
      channelName = Constants.defaultNotificationChannel;
    }
    await _flutterLocalNotificationsPlugin.show(
          888,
          title,
          message,
          new NotificationDetails(
            android: AndroidNotificationDetails(
              "Snap-Crescent",
              channelName,
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
    
  }

  clearNotifications() async{
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> isAndroidPermissionGranted() async {
    bool granted = false;
    if (Platform.isAndroid) {
      granted = await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;   
      }
    return granted;
  }

  Future<void> requestPermissions() async {
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

      await androidImplementation?.requestPermission();
    }
  }
}
