import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/screens/sync_process/sync_process.dart';
import 'package:snap_crescent/utils/constants.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[Expanded(child: _SplashScreenView())],
    ));
  }
}

class _SplashScreenView extends StatefulWidget {
  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<_SplashScreenView> {
  @override
  void initState() {
    super.initState();

    AppConfigResository.instance
        .findByKey(Constants.appConfigServerURL)
        .then((value) => {
              if (value.configValue == null)
                {
                  Timer(
                      Duration(seconds: 1),
                      () => Navigator.pushReplacementNamed(
                          context, LoginScreen.routeName))
                }
              else
                {
                  Timer(
                      Duration(seconds: 1),
                      () => Navigator.pushReplacementNamed(
                          context, SyncProcessScreen.routeName))
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black, child: Image.asset("assets/images/logo.png"));
  }
}
