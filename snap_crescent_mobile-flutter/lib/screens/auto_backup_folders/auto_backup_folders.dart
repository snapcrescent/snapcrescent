import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/style.dart';
import 'package:snap_crescent/utils/constants.dart';

class AutoBackupFoldersScreen extends StatelessWidget {
  static const routeName = '/auto_backup_folders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Device Folders'),
          backgroundColor: Colors.black,
        ),
        body: _AutoBackupFoldersScreenView());
  }
}

class _AutoBackupFoldersScreenView extends StatefulWidget {
  @override
  _AutoBackupFoldersScreenViewState createState() =>
      _AutoBackupFoldersScreenViewState();
}

class _AutoBackupFoldersScreenViewState
    extends State<_AutoBackupFoldersScreenView> {
  List<bool> _autoBackupFolderStatusList = [];
  List<String> _autoBackupFolderList = [];
  String _autoBackupFolders = "None";

  Future<List<AssetPathEntity>> _getDeviceFolderList() async {
    await _getAutoBackupInfo();
    await _getAutoBackupFolderInfo();

    if (!await PhotoManager.requestPermission()) {
      ToastService.showError('Permission to device folders denied!');
      return Future.value([]);
    }

    final List<AssetPathEntity> assets = await PhotoManager.getAssetPathList();
    assets.sort((AssetPathEntity a, AssetPathEntity b) =>
        a.name.compareTo(b.name));

    List<String> autoBackupFolderNameList = _autoBackupFolders.split(",");

    _autoBackupFolderStatusList = assets.map((asset) => autoBackupFolderNameList.indexOf(asset.id) > 0 ? true : false).toList();
    _autoBackupFolderList = assets.map((asset) => asset.id).toList();

    return Future.value(assets);
  }

  Future<void> _getAutoBackupInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigAutoBackupFlag);

    if (value.configValue != null) {
      //_autoBackup = value.configValue == 'true' ? true : false;
    }
  }

  Future<void> _getAutoBackupFolderInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigAutoBackupFolders);

    if (value.configValue != null) {
      _autoBackupFolders = value.configValue!;
    }
  }

  _updateAppConfigAutoBackupFolders(int index, bool value) async {
    _autoBackupFolderStatusList[index] = value;

    List<String> newAutoBackupFolderList = [];
    for(int i = 0 ; i < _autoBackupFolderStatusList.length ; i++) {
      if(_autoBackupFolderStatusList[i] == true) {
        newAutoBackupFolderList.add(_autoBackupFolderList[i]);
      }
    }

    AppConfig appConfigAutoBackupFoldersConfig = new AppConfig(
        configkey: Constants.appConfigAutoBackupFolders,
        configValue: newAutoBackupFolderList.join(","));

    await AppConfigResository.instance
        .saveOrUpdateConfig(appConfigAutoBackupFoldersConfig);

    setState(() {});
  }

  _deviceFolderList(BuildContext context, List<AssetPathEntity> assets) {
    return new ListView.builder(
        itemCount: assets.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return new SwitchListTile(
            title: Text(assets[index].name, style: TitleTextStyle),
            secondary: const Icon(Icons.folder),
            value: _autoBackupFolderStatusList[index],
            onChanged: (bool value) {
              _updateAppConfigAutoBackupFolders(index,value);
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetPathEntity>>(
        future: _getDeviceFolderList(),
        builder: (BuildContext context,
            AsyncSnapshot<List<AssetPathEntity>> snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            return _deviceFolderList(context, snapshot.data!);
          }
        });
  }
}
