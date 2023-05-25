import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/screens/settings/settings.dart';

import 'package:snap_crescent/services/settings_service.dart';
import 'package:snap_crescent/utils/constants.dart';

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

  _getAppConfigs() {
    SettingsService.instance
        .getFlag(Constants.appConfigLoggedInFlag)
        .then((value) => {
          _loggedInToServer = value,
          setState(() {})
          });

    SettingsService.instance
        .getFlag(Constants.appConfigShowLoginPromptFlag, true)
        .then((value) => {
          _showLoginPrompt = value,
          setState(() {})
          });

    SettingsService.instance
        .getFlag(Constants.appConfigAutoBackupFlag)
        .then((value) => {
          _autoBackupConfigured = value,
          setState(() {})
          });
    
    SettingsService.instance
        .getFlag(Constants.appConfigShowAutoBackupPromptFlag, true)
        .then((value) => {
          _showAutoBackupPrompt = value,
          setState(() {})
          });
          
  }

  _body() {
    if (_loggedInToServer) {
      if(!_autoBackupConfigured && _showAutoBackupPrompt) {
        return Container(
          color: Colors.grey.shade800,
          width: double.infinity,
          height: 150,
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.cloud_off_sharp, color: Colors.teal, size: 50),
              Text("Auto Backup is disabled",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _onDoNotShowAutoBackUpPromptAgain();
                    },
                    child: Text('Do not show again'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) => SettingsScreen()));
                    },
                    child: Text('Enable Auto Backup now'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                ],
              )
            ],
          ));
      } else {
        return Container();
      }
    } else if (_showLoginPrompt){
      return Container(
          color: Colors.grey.shade800,
          width: double.infinity,
          height: 150,
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.cloud_off_sharp, color: Colors.teal, size: 50),
              Text("Not logged in your Snapcrescent Server",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _onDoNotShowLoginPromptAgain();
                    },
                    child: Text('Do not show again'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) => SettingsScreen()));
                    },
                    child: Text('Login now'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                ],
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  _onDoNotShowLoginPromptAgain() async{

    AppConfig appConfigShowLoginPromptFlagConfig = new AppConfig(
                        configKey: Constants.appConfigShowLoginPromptFlag,
                        configValue: false.toString());

    await AppConfigRepository.instance.saveOrUpdateConfig(appConfigShowLoginPromptFlagConfig);

    _getAppConfigs();

  }

  _onDoNotShowAutoBackUpPromptAgain() async{

    AppConfig appConfigShowAutoBackupPromptFlagConfig = new AppConfig(
                        configKey: Constants.appConfigShowAutoBackupPromptFlag,
                        configValue: false.toString());

    await AppConfigRepository.instance.saveOrUpdateConfig(appConfigShowAutoBackupPromptFlagConfig);

    _getAppConfigs();

  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }
}
