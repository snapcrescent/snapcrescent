import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionUtilities {

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<bool> checkAndAskForAllStoragePermission() async {
    return await _checkAndAskForPermission(Permission.manageExternalStorage);
  }

  Future<bool> checkAndAskForPhotosPermission() async {
    return await _checkAndAskForPermission(Permission.photos);
  }

  Future<bool> checkAndAskForNotificationPermission() async {
    bool granted = await isNotificationPermissionGranted();

    if (!granted) {
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
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.requestPermission();
      }
    }
    return await isNotificationPermissionGranted();
  }

  Future<bool> isNotificationPermissionGranted() async {
    bool granted = false;
    if (Platform.isAndroid) {
      granted = await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
    return granted;
  }

  Future<bool> _checkAndAskForPermission(Permission permission) async {
    if (Platform.isAndroid) {
      final status = await permission.status;
      if (status.isDenied) {
        final result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
}
