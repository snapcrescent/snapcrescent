//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering, depend_on_referenced_packages
// ignore_for_file: lines_longer_than_80_chars

import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:wakelock_web/wakelock_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  FluttertoastWebPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  WakelockWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
