import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:snap_crescent/app.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async{
    ToastService.showSuccess("BG Process running $task");
    await AssetService().saveOnCloud();
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  
  Workmanager().registerOneOffTask("registerOneOffTask", "registerOneOffTask");
  // Periodic task registration
  /*
  Workmanager().registerPeriodicTask(
      "2", 
      "simplePeriodicTask", 
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 30)
  );
  */

  await FlutterDownloader.initialize(
    debug: true // optional: set false to disable printing logs to console
  );

  runApp(App());
}