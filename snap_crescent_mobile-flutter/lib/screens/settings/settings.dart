import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/user_login_response.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/screens/settings/folder_seletion/folder_selection.dart';
import 'package:snap_crescent/services/login_service.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/stores/cloud/asset_store.dart';
import 'package:snap_crescent/stores/cloud/photo_store.dart';
import 'package:snap_crescent/stores/cloud/video_store.dart';
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
  String _lastSyncDate = "Never";
  String _autoBackupFolders = "None";
  String _showDeviceAssetsFolders = "None";

  AssetStore? photoStore;
  AssetStore? videoStore;

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
    photoStore = Provider.of<PhotoStore>(context);
    videoStore = Provider.of<VideoStore>(context);

    return FutureBuilder<bool>(
        future: _getSettingsData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == null) {
            return Container();
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
    await _getAutoBackupInfo();
    await _getAutoBackupFolderInfo();
    await _getShowDeviceAssetsInfo();
    await _getShowDeviceAssetsFolderInfo();
    await _getLastSyncInfo();
    return Future.value(true);
  }

  _clearCache() async {
    await SyncInfoService().deleteAllData();
    await _getLastSyncInfo();
    ToastService.showSuccess("Successfully deleted locally cached data.");
    await _refreshAssetStores();
    setState(() {});
  }

  Future<void> _getAccountInfo() async {
 
    AppConfig appConfigLoggedInFlag = await AppConfigRepository.instance.findByKey(Constants.appConfigLoggedInFlag);

    if (appConfigLoggedInFlag.configValue != null) {
          _connectedToServer = appConfigLoggedInFlag.configValue == "true" ? true : false;
    }

    AppConfig appConfigServerURL = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerURL);

    if (appConfigServerURL.configValue != null) {
      
      this.serverURLController.text = appConfigServerURL.configValue!;
      _loggedServerName = this.serverURLController.text;
      _loggedServerName = _loggedServerName.replaceAll("http://", "");
      _loggedServerName = _loggedServerName.replaceAll("https://", "");
      _loggedServerName =
          _loggedServerName.substring(0, _loggedServerName.lastIndexOf(":"));
    } else {
      this.serverURLController.text = "http://192.168.0.62:8080";
    }

    AppConfig appConfigServerUserName = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerUserName);

    if (appConfigServerUserName.configValue != null) {
      this.nameController.text = appConfigServerUserName.configValue!;
      _loggedInUserName = this.nameController.text;
    } else {
      this.nameController.text = "";
    }

    AppConfig appConfigServerPassword = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerPassword);

    if (appConfigServerPassword.configValue != null) {
      this.passwordController.text = appConfigServerPassword.configValue!;
    } else {
      this.passwordController.text = "";
    }
  }

  Future<void> _getAutoBackupInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigAutoBackupFlag);

    if (value.configValue != null) {
      _autoBackup = value.configValue == 'true' ? true : false;
    }
  }

  Future<void> _getAutoBackupFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigAutoBackupFolders);

    if (value.configValue != null) {
      List<String> autoBackupFolderIdList = value.configValue!.split(",");

      final List<AssetPathEntity> assets =
          await PhotoManager.getAssetPathList();
      List<String> autoBackupFolderNameList = assets
          .where((asset) => autoBackupFolderIdList.indexOf(asset.id) > -1)
          .map((asset) => asset.name)
          .toList();

      if (autoBackupFolderNameList.isEmpty) {
        _autoBackupFolders = "None";
      } else if (autoBackupFolderNameList.length == assets.length) {
        _autoBackupFolders = "All";
      } else {
        _autoBackupFolders = autoBackupFolderNameList.join(", ");
      }
    }
  }

  Future<void> _getShowDeviceAssetsInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFlag);

    if (value.configValue != null) {
      _showDeviceAssets = value.configValue == 'true' ? true : false;
    }
  }

  Future<void> _getShowDeviceAssetsFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFolders);

    if (value.configValue != null) {
      List<String> showDeviceAssetsFolderIdList = value.configValue!.split(",");

      final List<AssetPathEntity> assets =
          await PhotoManager.getAssetPathList();
      List<String> showDeviceAssetsFolderNameList = assets
          .where((asset) => showDeviceAssetsFolderIdList.indexOf(asset.id) > -1)
          .map((asset) => asset.name)
          .toList();

      if (showDeviceAssetsFolderNameList.isEmpty) {
        _showDeviceAssetsFolders = "None";
      } else if (showDeviceAssetsFolderNameList.length == assets.length) {
        _showDeviceAssetsFolders = "All";
      } else {
        _showDeviceAssetsFolders = showDeviceAssetsFolderNameList.join(", ");
      }
    }
  }

  Future<void> _getLastSyncInfo() async {
    List<SyncInfo> localSyncInfoList = await SyncInfoService().searchOnLocal();

    if (localSyncInfoList.isEmpty == false) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss ');
      _lastSyncDate =
          formatter.format(localSyncInfoList.last.lastModifiedDatetime!);
    } else {
      _lastSyncDate = "Never";
    }
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
          if(_connectedToServer) 
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

      AppConfig appConfigLoggedInFlagConfig = new AppConfig(
          configkey: Constants.appConfigLoggedInFlag,
          configValue: true.toString());

      AppConfig serverUrlConfig = new AppConfig(
          configkey: Constants.appConfigServerURL,
          configValue: serverURLController.text);

      AppConfig serverUserNameConfig = new AppConfig(
          configkey: Constants.appConfigServerUserName,
          configValue: nameController.text);

      AppConfig serverPasswordConfig = new AppConfig(
          configkey: Constants.appConfigServerPassword,
          configValue: passwordController.text);

      await AppConfigRepository.instance.saveOrUpdateConfig(serverUrlConfig);
      await AppConfigRepository.instance.saveOrUpdateConfig(serverUserNameConfig);
      await AppConfigRepository.instance.saveOrUpdateConfig(serverPasswordConfig);

      UserLoginResponse userLoginResponse = await LoginService().login();

      if(userLoginResponse.token != null) {
          await AppConfigRepository.instance.saveOrUpdateConfig(appConfigLoggedInFlagConfig);
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
          configkey: Constants.appConfigLoggedInFlag,
          configValue: false.toString());

      await AppConfigRepository.instance.saveOrUpdateConfig(appConfigLoggedInFlagConfig);
      await _getAccountInfo();
      setState(() {});
      Navigator.pop(context);
  }

  _updateAutoBackupFlag(bool value) async {
    _autoBackup = value;
    AppConfig appConfigAutoBackupFlagConfig = new AppConfig(
        configkey: Constants.appConfigAutoBackupFlag,
        configValue: value.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigAutoBackupFlagConfig);

    setState(() {});
  }

  _updateShowDeviceAssetsFlag(bool value) async {
    _showDeviceAssets = value;
    AppConfig appConfigShowDeviceAssetsFlagConfig = new AppConfig(
        configkey: Constants.appConfigShowDeviceAssetsFlag,
        configValue: value.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigShowDeviceAssetsFlagConfig);
    await _refreshAssetStores();
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
          width: 10,
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
            "Keep your photos and videos by backing them up to your snap-crecent server"),
        isThreeLine: true,
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
            width: 10,
            alignment: Alignment.center,
            child: const Icon(Icons.folder),
          ),
          onTap: () {
            AppConfig appConfigAutoBackupFoldersConfig = new AppConfig(
                configkey: Constants.appConfigAutoBackupFolders,
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
        subtitle: Text("Last Synced : " + _lastSyncDate),
        leading: Container(
          width: 10,
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
        subtitle: Text("Show photos and videos on your device on snap-cresent"),
        isThreeLine: true,
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
            width: 10,
            alignment: Alignment.center,
            child: const Icon(Icons.folder),
          ),
          onTap: () {
            AppConfig appConfigShowDeviceAssetsFoldersFlagConfig =
                new AppConfig(
                    configkey: Constants.appConfigShowDeviceAssetsFolders,
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

  _refreshAssetStores() async {
    await this.photoStore!.getAssets(false);
    await this.videoStore!.getAssets(false);
  }

  @override
  void initState() {
    super.initState();
  }
}
