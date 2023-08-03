import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';

import 'package:snapcrescent_mobile/utils/constants.dart';

class ConfigServerPromptWidget extends StatefulWidget {
  @override
  ConfigServerPromptWidgetState createState() =>
      ConfigServerPromptWidgetState();
}

class ConfigServerPromptWidgetState extends State<ConfigServerPromptWidget> {
  bool _showLoginPrompt = false;
  bool _loggedInToServer = false;

  bool _showAutoBackupPrompt = false;
  bool _autoBackupConfigured = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAppConfigs();

      timer =
          Timer.periodic(Duration(seconds: 5), (Timer t) => _getAppConfigs());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<bool> _getAppConfigs() async {
    _loggedInToServer = await AppConfigService()
        .getFlag(Constants.appConfigLoggedInFlag);
    _showLoginPrompt = await AppConfigService()
        .getFlag(Constants.appConfigShowLoginPromptFlag, true);
    _autoBackupConfigured = await AppConfigService()
        .getFlag(Constants.appConfigAutoBackupFlag);
    _showAutoBackupPrompt = await AppConfigService()
        .getFlag(Constants.appConfigShowAutoBackupPromptFlag, true);

    return Future.value(true);
  }

  _body() {
    return Container(
        height: 100, width: 400, alignment: Alignment.center, child: _getPrompt());
  }

  _getPrompt() {
    if (_loggedInToServer) {
      if (!_autoBackupConfigured && _showAutoBackupPrompt) {
        return _enableBackupPrompt();
      } else {
        return Container();
      }
    } else if (_showLoginPrompt) {
      return _loginPrompt();
    } else {
      return Container();
    }
  }

  _getContainerDecoration() {
    return BoxDecoration(
      color: Colors.black,
      border: Border.all(
        color: Colors.black,
      ),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.teal.withOpacity(0.5), //color of shadow
          spreadRadius: 3, //spread radius
          blurRadius: 3, // blur radius
          offset: Offset(0, -2), // changes position of shadow
          //first paramerter of offset is left-right
          //second parameter is top to down
        ),
        //you can set more BoxShadow() here
      ],
    );
  }

  _loginPrompt() {
    return Container(
        decoration: _getContainerDecoration(),
        child: Column(
          children: [
            Text("Not logged in your Snapcrescent Server",
                style: TextStyle(color: Colors.white, fontSize: 16, height: 2)),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _onDoNotShowLoginPromptAgain();
                  },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  child: Text('Do not show again'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => SettingsScreen()));
                  },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  child: Text('Login now'),
                ),
              ],
            )
          ],
        ));
  }

  _enableBackupPrompt() {
    return Container(
        decoration: _getContainerDecoration(),
        child: Column(
          children: [
            Text("Auto Backup is disabled",
                style: TextStyle(color: Colors.white, fontSize: 16, height: 2)),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _onDoNotShowAutoBackUpPromptAgain();
                  },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  child: Text('Do not show again'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => SettingsScreen()));
                  },
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  child: Text('Enable Auto Backup now'),
                ),
              ],
            )
          ],
        ));
  }

  _onDoNotShowLoginPromptAgain() async {
    await AppConfigService()
        .updateFlag(Constants.appConfigShowLoginPromptFlag, false);
    _getAppConfigs();
    setState(() {});
  }

  _onDoNotShowAutoBackUpPromptAgain() async {
    await AppConfigService()
        .updateFlag(Constants.appConfigShowAutoBackupPromptFlag, false);
    _getAppConfigs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getAppConfigs(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return SizedBox();
          } else {
            return _body();
          }
        });
  }
}
