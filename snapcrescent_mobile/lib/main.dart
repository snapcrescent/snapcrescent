import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:snapcrescent_mobile/app.dart';
import 'package:snapcrescent_mobile/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await BackgroundService.instance.initializeService();
  runApp(App());
}
