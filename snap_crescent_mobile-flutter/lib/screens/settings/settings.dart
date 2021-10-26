import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/screens/login/login.dart';
import 'package:snap_crescent/screens/settings/folder_seletion/folder_selection.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/stores/cloud/asset_store.dart';
import 'package:snap_crescent/stores/cloud/photo_store.dart';
import 'package:snap_crescent/stores/cloud/video_store.dart';
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
  bool _showDeviceAssets = false;
  String _lastSyncDate = "Never";
  String _autoBackupFolders = "None";
  String _showDeviceAssetsFolders = "None";

  AssetStore? photoStore;
  AssetStore? videoStore;

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

  Future<bool> _getSettingsData() async{
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
    setState(() {
      
    });
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

  Future<void> _getShowDeviceAssetsInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFlag);

    if (value.configValue != null) {
      _showDeviceAssets = value.configValue == 'true' ? true : false;
    }
  }

  Future<void> _getShowDeviceAssetsFolderInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFolders);

    if (value.configValue != null) {
      List<String> showDeviceAssetsFolderIdList = value.configValue!.split(",");
      
      final List<AssetPathEntity> assets = await PhotoManager.getAssetPathList();
      List<String> showDeviceAssetsFolderNameList = assets.where((asset) => showDeviceAssetsFolderIdList.indexOf(asset.id) > -1).map((asset) => asset.name).toList();

      if(showDeviceAssetsFolderNameList.isEmpty) {
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
      _lastSyncDate = formatter.format(localSyncInfoList.last.lastModifiedDatetime!);
    } else {
      _lastSyncDate = "Never";
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

  _updateShowDeviceAssetsFlag(bool value) async {
    _showDeviceAssets = value;
    AppConfig appConfigShowDeviceAssetsFlagConfig = new AppConfig(
        configkey: Constants.appConfigShowDeviceAssetsFlag,
        configValue: value.toString());

    await AppConfigResository.instance
        .saveOrUpdateConfig(appConfigShowDeviceAssetsFlagConfig);
    await _refreshAssetStores();
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
             AppConfig appConfigAutoBackupFlagConfig = new AppConfig(
                configkey: Constants.appConfigAutoBackupFlag,
                configValue: "");

            Navigator.push(context,MaterialPageRoute(builder: (context) => FolderSelectionScreen(appConfigAutoBackupFlagConfig))).then(onBackFromChild);
          },
        ),
      ListTile(
        title: Text("Clear Locally Cached Photos and Videos", style: TitleTextStyle),
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
        title: Text("Show Device Phtos And Videos", style: TitleTextStyle),
        secondary: const Icon(Icons.photo_album),
        subtitle: Text(
            "Show photos and videos on your device on snap-cresent"),
        isThreeLine: true,
        value: _showDeviceAssets,
        onChanged: (bool value) {
          _updateShowDeviceAssetsFlag(value);
        },
      ),
      if (_showDeviceAssets)
        ListTile(
          title: Text("Device Folders", style: TitleTextStyle),
          subtitle: Text(_showDeviceAssetsFolders
          ),
          leading: Container(
            width: 10,
            alignment: Alignment.center,
            child: const Icon(Icons.folder),
          ),
          onTap: () {
             AppConfig appConfigShowDeviceAssetsFoldersFlagConfig = new AppConfig(
                configkey: Constants.appConfigShowDeviceAssetsFolders,
                configValue: "");
            Navigator.push(context,MaterialPageRoute(builder: (context) => FolderSelectionScreen(appConfigShowDeviceAssetsFoldersFlagConfig))).then(onBackFromChild);
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

  _refreshAssetStores() async {
    await this.photoStore!.getAssets(false);
    await this.videoStore!.getAssets(false);
  }

  @override
  void initState() {
    super.initState();
  }

  
}
