import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/screens/auto_backup_folders/auto_backup_folders.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/style.dart';
import 'package:snap_crescent/utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.black,
        ),
        body: _SettingsScreenView());
  }
}

class _SettingsScreenView extends StatefulWidget {
  @override
  _SettingsScreenViewState createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends State<_SettingsScreenView> {
  bool _autoBackup = false;
  String _lastSyncDate = "Never";
  String _autoBackupFolders = "None";

  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async{
    await _getAutoBackupInfo();
    await _getAutoBackupFolderInfo();
    await _getLastSyncInfo();
    return Future.value(true);
  }

  _clearCache() async {
    await SyncInfoService().deleteAllData();
  }

  Future<void> _getAutoBackupInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigAutoBackupFlag);

    if (value.configValue != null) {
      _autoBackup = value.configValue == 'true' ? true : false;
    }
  }

  Future<void> _getAutoBackupFolderInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigAutoBackupFolders);

    if (value.configValue != null) {
      List<String> autoBackupFolderIdList = value.configValue!.split(",");
      
      final List<AssetPathEntity> assets = await PhotoManager.getAssetPathList();
      List<String> autoBackupFolderNameList = assets.where((asset) => autoBackupFolderIdList.indexOf(asset.id) > -1).map((asset) => asset.name).toList();

      if(autoBackupFolderNameList.isEmpty) {
        _autoBackupFolders = "None";
      } else if (autoBackupFolderNameList.length == assets.length) {
        _autoBackupFolders = "All";
      } else {
        _autoBackupFolders = autoBackupFolderNameList.join(", ");
      }
    }
  }

  Future<void> _getLastSyncInfo() async {
    List<SyncInfo> localSyncInfoList = await SyncInfoService().searchOnLocal();

    if (localSyncInfoList.isEmpty == false) {
        final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss ');
      _lastSyncDate = formatter.format(localSyncInfoList.last.lastModifiedDatetime!);
    }
  }

  _updateAutoBackupFlag(bool value) async {
    _autoBackup = value;
    AppConfig appConfigAutoBackupFlagConfig = new AppConfig(
        configkey: Constants.appConfigAutoBackupFlag,
        configValue: value.toString());

    await AppConfigResository.instance
        .saveOrUpdateConfig(appConfigAutoBackupFlagConfig);

    setState(() {});
  }

  _settingsList(BuildContext context) {
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
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
            Navigator.push(context,MaterialPageRoute(builder: (context) => AutoBackupFoldersScreen())).then(onBackFromChild);
          },
        ),
      ListTile(
        title: Text("Clear Synced Photos and Videos", style: TitleTextStyle),
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
      ListTile(
        title: Text("Logout", style: TitleTextStyle),
        leading: Container(
          width: 10,
          alignment: Alignment.center,
          child: const Icon(Icons.logout),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
              context, LoginScreen.routeName, (r) => false);
        },
      )
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
              return Container();
            } else {
              return _settingsList(context);
            }
          });
  }
}
