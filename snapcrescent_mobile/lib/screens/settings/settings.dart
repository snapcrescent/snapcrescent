import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapcrescent_mobile/models/user/account_info.dart';
import 'package:snapcrescent_mobile/models/user/user_login_response.dart';
import 'package:snapcrescent_mobile/screens/settings/widgets/auto_backup_settings.dart';
import 'package:snapcrescent_mobile/screens/settings/widgets/device_folders_settings.dart';
import 'package:snapcrescent_mobile/screens/settings/widgets/files_settings.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/login_service.dart';
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/widgets/footer.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
            backgroundColor: Colors.black,
          ),
          bottomNavigationBar: Footer(),
          body: _SettingsScreenView());
  }
}

class _SettingsScreenView extends StatefulWidget {
  @override
  _SettingsScreenViewState createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<_SettingsScreenView> {
  bool _connectedToServer = false;
  String _loggedInUserName = "";
  String _loggedServerName = "";
  String _appVersion = "";
  
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final RegExp _urlRegex = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  TextEditingController serverURLController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {
    await _getAccountInfo();
    _connectedToServer =
        await AppConfigService().getFlag(Constants.appConfigLoggedInFlag);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _appVersion =
        '''Version : ${packageInfo.version}+${packageInfo.buildNumber}''';

    return Future.value(true);
  }

  Future<void> _getAccountInfo() async {
    AccountInfo accountInfo = await LoginService().getAccountInformation();

    serverURLController.text = accountInfo.serverUrl;
    _loggedServerName = serverURLController
        .text
        .replaceAll("https://", "")
        .replaceAll("http://", "");

    if(_loggedServerName.lastIndexOf(":") > -1) {
      _loggedServerName = _loggedServerName.substring(0, _loggedServerName.lastIndexOf(":"));
    }    
    

    nameController.text = accountInfo.username;
    _loggedInUserName = nameController.text;

    passwordController.text = accountInfo.password;
  }

  _showAccountInfoDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account'),
          content: SizedBox(
              height: 300,
              child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                          autovalidateMode: _autovalidateMode,
                          controller: serverURLController,
                          validator: (v) {
                            if (v!.isNotEmpty && _urlRegex.hasMatch(v)) {
                              return null;
                            } else {
                              return 'Please enter a valid url';
                            }
                          },
                          decoration: InputDecoration(labelText: 'Server URL')),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                    )
                  ]))),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            if (_connectedToServer)
              TextButton(
                child: const Text('Logout'),
                onPressed: () {
                  _onLogoutPressed();
                },
              )
            else
              TextButton(
                child: const Text('Login'),
                onPressed: () {
                  _onLoginPressed();
                },
              )
          ],
        );
      },
    );
  }

  

  _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {

      try {

      UserLoginResponse? userLoginResponse = await LoginService().login(serverURLController.text, nameController.text, passwordController.text);

      if (userLoginResponse != null) {
        await AppConfigService()
            .updateFlag(Constants.appConfigLoggedInFlag, true);
        await _getAccountInfo();
        await NotificationService().initialize();
        setState(() {});
        Navigator.pop(context);
      } else {
        ToastService.showError("Incorrect Username or Password");
        setState(() {
          _autovalidateMode = AutovalidateMode.always;
        });
      }
      } on Exception catch (ex) {
          ToastService.showError(ex.toString());
      }

      
    } else {
      ToastService.showError("Please fix the errors");
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }

  _onLogoutPressed() async {
    await AppConfigService().updateFlag(Constants.appConfigLoggedInFlag, false);
    await _getAccountInfo();
    setState(() {});
    Navigator.pop(context);
  }



 
  _settingsList(BuildContext context) {
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
        title: Text("Account", style: titleTextStyle),
        subtitle: Text(_connectedToServer == true
            ? '''$_loggedInUserName@$_loggedServerName'''
            : "Not Connected"),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.account_circle, color: Colors.teal),
        ),
        onTap: () {
          _showAccountInfoDialog();
        },
      ),
      if (_connectedToServer)
        AutoBackupSettingsView(),
      DeviceFoldersSettingsView(),
      FilesSettingsView(),
      ListTile(
        title: Text("About App", style: titleTextStyle),
        subtitle: Text(_appVersion),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.ac_unit_outlined, color: Colors.teal),
        ),
        onTap: () {},
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
        future: _getSettingsData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            return _settingsList(context);
          }
        });
  }
}
