
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/permission_utilities.dart';

class NotificationService {

  static final NotificationService _singleton = NotificationService._internal();

  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal();
  

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  

  Future initialize() async {
    await PermissionUtilities().checkAndAskForNotificationPermission();

    var androidInitialize = AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await _flutterLocalNotificationsPlugin.initialize(initializationsSettings);

  }

  Future registerBackgroundServiceNotification() async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Constants.notificationChannelId.toString(), // id
        'Snap-Crescent', // title
        description:
            'Snap-Crescent sync process notifications', // description
        importance: Importance.low, // importance must be at low or higher level
      );

    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  showNotification(String title,String message, [String? channelName]) async {
    if(await PermissionUtilities().isNotificationPermissionGranted()) {

      channelName ??= Constants.defaultNotificationChannel;
    await _flutterLocalNotificationsPlugin.show(
          Constants.notificationChannelId,
          title,
          message,
          NotificationDetails(
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

  showProgressNotification(String title,String message, int maxProgress, int progress, [String? channelName]) async {
    if(await PermissionUtilities().isNotificationPermissionGranted()) {

      channelName ??= Constants.defaultNotificationChannel;
    await _flutterLocalNotificationsPlugin.show(
          Constants.notificationChannelId,
          title,
          message,
          NotificationDetails(
            android: AndroidNotificationDetails(
              "Snap-Crescent",
              channelName,
              channelShowBadge: false,
              importance:Importance.max,
              priority:Priority.high,
              onlyAlertOnce: true,
              showProgress: true,
              maxProgress: maxProgress,
              progress: progress
            ),
          ),
        );

    }
  }

  clearNotifications() async{
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

}
