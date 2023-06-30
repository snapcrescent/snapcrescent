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
    _loggedInToServer = await AppConfigService.instance.getFlag(Constants.appConfigAutoBackupFlag);
    _showLoginPrompt = await AppConfigService.instance.getFlag(Constants.appConfigShowLoginPromptFlag, true);
    _autoBackupConfigured = await AppConfigService.instance.getFlag(Constants.appConfigAutoBackupFlag);
    _showAutoBackupPrompt = await AppConfigService.instance.getFlag(Constants.appConfigShowAutoBackupPromptFlag, true);

    return Future.value(true);
  }

  _body() {
    if (_loggedInToServer) {
      if(!_autoBackupConfigured && _showAutoBackupPrompt) {
        return Container(
          color: Colors.grey.shade800,
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("Auto Backup is disabled",
                  style: TextStyle(color: Colors.white, fontSize: 16,height: 2)),
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
          height: 100,
          alignment: Alignment.center,
          child: Column(
            children: [
              Text("Not logged in your Snapcrescent Server",
                  style: TextStyle(color: Colors.white, fontSize: 16,height: 2)),
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
    await AppConfigService.instance.updateFlag(Constants.appConfigShowLoginPromptFlag, false); 
    _getAppConfigs();

  }

  _onDoNotShowAutoBackUpPromptAgain() async{
    await AppConfigService.instance.updateFlag(Constants.appConfigShowAutoBackupPromptFlag, false); 
    _getAppConfigs();

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getAppConfigs(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Container(
                width: 60,
                height: 60,
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            return _body();
          }
        });
  }
}
