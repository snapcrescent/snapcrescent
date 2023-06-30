import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/app.dart';
import 'package:snapcrescent_mobile/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.instance.initializeService();
  runApp(App());
}
