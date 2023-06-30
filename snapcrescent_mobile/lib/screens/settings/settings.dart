import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapcrescent_mobile/models/user_login_response.dart';
import 'package:snapcrescent_mobile/screens/grid/assets_grid.dart';
import 'package:snapcrescent_mobile/screens/settings/widgets/auto_backup_settings.dart';
import 'package:snapcrescent_mobile/screens/settings/widgets/device_folders_settings.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/services/settings_service.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {

        Navigator.popAndPushNamed(
          context,
          AssetsGridScreen.routeName,
           //if you want to disable back feature set to false
        );

        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
            backgroundColor: Colors.black,
          ),
          body: _SettingsScreenView()),
    );
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
  bool _cacheLocally = false;
  String _latestAssetDate = "Never";
  int _syncedAssetCount = 0;
  String _appVersion = "";
  
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.onUserInteraction;

  final RegExp _urlRegex = RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);

  TextEditingController serverURLController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late AssetStore _assetStore;

  

  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {
    await _getAccountInfo();
    _connectedToServer =
        await AppConfigService.instance.getFlag(Constants.appConfigLoggedInFlag);
    _cacheLocally = await AppConfigService.instance
        .getFlag(Constants.appConfigCacheLocallyFlag);
    _latestAssetDate = DateUtilities().formatDate(
        (await AssetService.instance.getLatestAssetDate()),
        DateUtilities.timeStampFormat);

    _syncedAssetCount = await AssetService.instance.countOnLocal();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _appVersion =
        '''Version : ${packageInfo.version}+${packageInfo.buildNumber}''';

    return Future.value(true);
  }

  Future<void> _getAccountInfo() async {
    List<String> result =
        await SettingsService.instance.getAccountInformation();

    this.serverURLController.text = result[0];
    _loggedServerName = this
        .serverURLController
        .text
        .replaceAll("https://", "")
        .replaceAll("http://", "");

    if(_loggedServerName.lastIndexOf(":") > -1) {
      _loggedServerName = _loggedServerName.substring(0, _loggedServerName.lastIndexOf(":"));
    }    
    

    this.nameController.text = result[1];
    _loggedInUserName = this.nameController.text;

    this.passwordController.text = result[2];
  }

  _showAccountInfoDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account'),
          content: Container(
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
                            if (v!.length > 0 && _urlRegex.hasMatch(v)) {
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

  
  _showCacheClearConfirmationDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('This action cannot be undone')],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                _clearCache();
              },
            )
          ],
        );
      },
    );
  }

  _clearCache() async {
    await AssetService.instance.deleteAllData();
    await _assetStore.refreshStore();
    _latestAssetDate = DateUtilities().formatDate(
        (await AssetService.instance.getLatestAssetDate()),
        DateUtilities.timeStampFormat);
    await AppConfigService.instance.updateDateConfig(Constants.appConfigLastSyncActivityTimestamp, DateTime(2000, 1, 1, 0, 0, 0, 0, 0), DateUtilities.timeStampFormat);
    ToastService.showSuccess("Successfully deleted locally cached data.");
    setState(() {});
    Navigator.pop(context);
  }

  _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {

      try {

      UserLoginResponse? userLoginResponse = await SettingsService.instance
          .saveAccountInformation(serverURLController.text, nameController.text,
              passwordController.text);

      if (userLoginResponse != null) {
        await AppConfigService.instance
            .updateFlag(Constants.appConfigLoggedInFlag, true);
        await _getAccountInfo();
        await NotificationService.instance.initialize();
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
    await AppConfigService.instance.updateFlag(Constants.appConfigLoggedInFlag, false);
    await _getAccountInfo();
    setState(() {});
    Navigator.pop(context);
  }



  _updateCacheLocallyFlag(bool value) async {
    _cacheLocally = value;
    await AppConfigService.instance
        .updateFlag(Constants.appConfigCacheLocallyFlag, value);
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
          child: const Icon(Icons.account_circle, color: Colors.teal),
        ),
        onTap: () {
          _showAccountInfoDialog();
        },
      ),
      if (_connectedToServer)
        AutoBackupSettingsView(),
      DeviceFoldersSettingsView(),
      ListTile(
          title: Text("Cache Photos and Videos Locally", style: TitleTextStyle),
          subtitle: Text(
              "Automatically download photos and videos from your snap-crescent server"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.cloud_upload, color: Colors.teal),
          ),
          trailing: Switch(
              value: _cacheLocally,
              onChanged: (bool value) {
                _updateCacheLocallyFlag(value);
              }),
        ),
      if (_cacheLocally)
        ListTile(
          title: Text("Local Cache Age ", style: TitleTextStyle),
          subtitle: Text(""),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.sync, color: Colors.teal),
          ),
          onTap: () {
          },
        ),
      ListTile(
        title: Text("Delete Synced Photos and Videos", style: TitleTextStyle),
        subtitle: Text("Last Sync: " +
            (_latestAssetDate.isEmpty ? "Never" : _latestAssetDate) +
            "\n" +
            "Synced Pictures and Videos Count : " +
            _syncedAssetCount.toString()),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.delete, color: Colors.teal),
        ),
        onTap: () {
          _showCacheClearConfirmationDialog();
        },
      ),
      ListTile(
        title: Text("About App", style: TitleTextStyle),
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

    _assetStore = Provider.of<AssetStore>(context);

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
}
