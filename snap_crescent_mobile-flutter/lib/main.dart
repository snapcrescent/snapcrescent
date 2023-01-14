import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:snap_crescent/app.dart';
import 'package:snap_crescent/services/global_service.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher()
 {
   Workmanager().executeTask((taskName, inputData) {
    
    switch (taskName) {
      case "Asset-Sync":
        GlobalService.instance.syncProcessStore!.startSyncProcess();
        break;
    }

    return Future.value(true);
   });
 }
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  await FlutterDownloader.initialize(
    debug: true // optional: set false to disable printing logs to console
  );

  runApp(App());
}