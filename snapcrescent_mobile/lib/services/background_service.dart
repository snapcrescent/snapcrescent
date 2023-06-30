import 'dart:io';

import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/models/sync_state.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/services/sync_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class BackgroundService {
  BackgroundService._privateConstructor() : super();
  static final BackgroundService instance = BackgroundService._privateConstructor();

  FlutterBackgroundService? service;

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // bring to foreground
    Timer.periodic(const Duration(hours: 1), (timer) async {

       // test using external plugin
      final deviceInfo = DeviceInfoPlugin();
      String? device;
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        device = androidInfo.model;
      }

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        device = iosInfo.model;
      }

      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {

          DateTime lastSyncTime = DateTime.now();
          AppConfig lastSyncTimeValue = await AppConfigRepository.instance.findByKey(Constants.appConfigLastSyncActivityTimestamp);
          if(lastSyncTimeValue.configValue != null) {
              lastSyncTime  = DateUtilities().parseDate(lastSyncTimeValue.configValue!, DateUtilities.timeStampFormat) ;
          }

          AppConfig autoBackupFrequencyValue = await AppConfigRepository.instance.findByKey(Constants.appConfigAutoBackupFrequency);
          if(autoBackupFrequencyValue.configValue != null) {
            int autoBackupFrequency = int.parse(autoBackupFrequencyValue.configValue!);
            int minutesSinceLastBackup =  DateUtilities().calculateMinutesBetween(lastSyncTime, DateTime.now());

            if(minutesSinceLastBackup > autoBackupFrequency) {
            await PhotoManager.setIgnorePermissionCheck(true);
            await SyncService().syncAssets((SyncState syncMetadata) => {
              service.invoke(
              'update',
              {
                "current_date": DateTime.now().toIso8601String(),
                "device": device,
                "syncMetadata": syncMetadata
              },
            )
            });
            } 
          }
        }
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }

  Future<void> initializeService() async {
  
      service = FlutterBackgroundService();

      AndroidConfiguration androidConfiguration;

      if(await NotificationService.instance.isAndroidPermissionGranted()) {
        androidConfiguration = AndroidConfiguration(
          // this will be executed when app is in foreground or background in separated isolate
          onStart: onStart,

          // auto start service
          autoStart: true,
          autoStartOnBoot: true,
          isForegroundMode: true,

          notificationChannelId: Constants.notificationChannelId.toString(), // this must match with notification channel you created above.
          initialNotificationTitle: 'Snap-Crescent',
          initialNotificationContent: 'Initializing Server Sync',
          foregroundServiceNotificationId: Constants.notificationChannelId,
        );
      } else {
        androidConfiguration = AndroidConfiguration(
          // this will be executed when app is in foreground or background in separated isolate
          onStart: onStart,

          // auto start service
          autoStart: true,
          autoStartOnBoot: true,
          isForegroundMode: true,  
        );
      }

      IosConfiguration iosConfiguration = IosConfiguration(
          // auto start service
          autoStart: true,

          // this will be executed when app is in foreground in separated isolate
          onForeground: onStart,

          // you have to enable background fetch capability on xcode project
          onBackground: onIosBackground,
        );
      
      await service!.configure(
        androidConfiguration: androidConfiguration,
        iosConfiguration: iosConfiguration,
      );

      service!.startService();
  }

   Future<void> stopService() async {
        if(service != null) {
            service!.invoke("stopService");
        }
        
   }
}
