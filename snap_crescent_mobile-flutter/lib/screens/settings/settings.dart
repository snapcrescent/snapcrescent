import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/user_login_response.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/screens/settings/folder_selection/folder_selection.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/settings_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/style.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:snap_crescent/widgets/bottom-navigation_bar/bottom-navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.black,
        ),
        bottomNavigationBar: AppBottomNavigationBar(),
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
  bool _autoBackup = false;
  bool _showDeviceAssets = false;
  String _latestAssetDate = "Never";
  int _syncedAssetCount = 0;
  String _autoBackupFolders = "None";
  String _showDeviceAssetsFolders = "None";

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final RegExp _urlRegex = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  TextEditingController serverURLController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder<bool>(
        future: _getSettingsData(),
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
            return _settingsList(context);
          }
        });
  }

  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {
    await _getAccountInfo();
    _connectedToServer =
        await SettingsService.instance.getFlag(Constants.appConfigLoggedInFlag);
    _autoBackup =
        await SettingsService.instance.getFlag(Constants.appConfigAutoBackupFlag);
    _autoBackupFolders = await SettingsService.instance.getAutoBackupFolderInfo();
    _showDeviceAssets = await SettingsService.instance
        .getFlag(Constants.appConfigShowDeviceAssetsFlag);
    _showDeviceAssetsFolders =
        await SettingsService.instance.getShowDeviceAssetsFolderInfo();
     _latestAssetDate = await SettingsService.instance.getLatestAssetDate();

    _syncedAssetCount = await AssetService.instance.countOnLocal(AssetSearchCriteria.defaultCriteria());
    return Future.value(true);
  }

  _clearCache() async {
    await AssetService.instance.deleteAllData();
    _latestAssetDate = await SettingsService.instance.getLatestAssetDate();
    ToastService.showSuccess("Successfully deleted locally cached data.");
    setState(() {});
  }

  Future<void> _getAccountInfo() async {
    List<String> result = await SettingsService.instance.getAccountInformation();

    this.serverURLController.text = result[0];
    _loggedServerName = this.serverURLController.text.replaceAll("https://", "").replaceAll("http://", "");
    _loggedServerName = _loggedServerName.substring(0, _loggedServerName.lastIndexOf(":"));
    
    this.nameController.text = result[1];
    _loggedInUserName = this.nameController.text;
    
    this.passwordController.text = result[2];
  }

  _showAccountInfoDialog() {
    Alert(
        context: context,
        title: "Account",
        content: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  autovalidateMode: _autovalidateMode,
                  controller: serverURLController,
                  validator: (v) {
                    if (v!.length > 0 && _urlRegex.hasMatch(v)) {
                      return null;
                    } else {
                      return 'Please enter a valid url';
                    }
                  },
                  decoration: InputDecoration(labelText: 'Server'),
                ),
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
            ])),
        buttons: [
          if (_connectedToServer)
            DialogButton(
              onPressed: () => _onLogoutPressed(),
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          else
            DialogButton(
              onPressed: () => _onLoginPressed(),
              child: Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
        ]).show();
  }

  _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      UserLoginResponse userLoginResponse = await SettingsService.instance
          .saveAccountInformation(serverURLController.text, nameController.text,
              passwordController.text);

      if (userLoginResponse.token != null) {
        SettingsService.instance.updateFlag(Constants.appConfigLoggedInFlag, true);
        await _getAccountInfo();
        setState(() {});
        Navigator.pop(context);
      } else {
        ToastService.showError("Incorrect Username or Password");
        setState(() {
          _autovalidateMode = AutovalidateMode.always;
        });
      }
    } else {
      ToastService.showError("Please fix the errors");
      setState(() {
        _autovalidateMode = AutovalidateMode.always;
      });
    }
  }

  _onLogoutPressed() async {
    AppConfig appConfigLoggedInFlagConfig = new AppConfig(
        configKey: Constants.appConfigLoggedInFlag,
        configValue: false.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigLoggedInFlagConfig);
    await _getAccountInfo();
    setState(() {});
    Navigator.pop(context);
  }

  _updateAutoBackupFlag(bool value) async {
    _autoBackup = value;
    await SettingsService.instance
        .updateFlag(Constants.appConfigAutoBackupFlag, value);
    setState(() {});
  }

  _updateShowDeviceAssetsFlag(bool value) async {
    _showDeviceAssets = value;
    await SettingsService.instance
        .updateFlag(Constants.appConfigShowDeviceAssetsFlag, value);
    setState(() {});
  }

  _settingsList(BuildContext context) {
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
        title: Text("Account", style: TitleTextStyle),
        subtitle: Text(_connectedToServer == true
            ? '''$_loggedInUserName@$_loggedServerName'''
            : "Not Connected"),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.account_circle),
        ),
        onTap: () {
          _showAccountInfoDialog();
        },
      ),
      SwitchListTile(
        title: Text("Auto Backup", style: TitleTextStyle),
        secondary: const Icon(Icons.cloud_upload),
        subtitle: Text(
            "Keep your photos and videos by backing them up to your snapcrecent server"),
        isThreeLine: false,
        value: _autoBackup,
        onChanged: (bool value) {
          _updateAutoBackupFlag(value);
        },
      ),
      if (_autoBackup)
        ListTile(
          title: Text("Backup Folders", style: TitleTextStyle),
          subtitle: Text(_autoBackupFolders),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.folder),
          ),
          onTap: () {
            AppConfig appConfigAutoBackupFoldersConfig = new AppConfig(
                configKey: Constants.appConfigAutoBackupFolders,
                configValue: "");

            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FolderSelectionScreen(
                            appConfigAutoBackupFoldersConfig)))
                .then(onBackFromChild);
          },
        ),
      ListTile(
        title: Text("Clear Locally Cached Photos and Videos",
            style: TitleTextStyle),
        subtitle: Text("Last Synced : " + _latestAssetDate + " - " + "Asset Count : " + _syncedAssetCount.toString()),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.delete),
        ),
        onTap: () {
          _clearCache();
        },
      ),
      SwitchListTile(
        title: Text("Show Device Photos And Videos", style: TitleTextStyle),
        secondary: const Icon(Icons.photo_album),
        subtitle: Text("Show photos and videos on your device on snapcresent"),
        isThreeLine: false,
        value: _showDeviceAssets,
        onChanged: (bool value) {
          _updateShowDeviceAssetsFlag(value);
        },
      ),
      if (_showDeviceAssets)
        ListTile(
          title: Text("Device Folders", style: TitleTextStyle),
          subtitle: Text(_showDeviceAssetsFolders),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.folder),
          ),
          onTap: () {
            AppConfig appConfigShowDeviceAssetsFoldersFlagConfig =
                new AppConfig(
                    configKey: Constants.appConfigShowDeviceAssetsFolders,
                    configValue: "");
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FolderSelectionScreen(
                            appConfigShowDeviceAssetsFoldersFlagConfig)))
                .then(onBackFromChild);
          },
        )
    ]);
  }

  @override
  void initState() {
    super.initState();
  }
}
