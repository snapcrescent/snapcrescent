import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/style.dart';

class FolderSelectionScreen extends StatelessWidget {
  static const routeName = '/folder_selection';

  final AppConfig appConfigShowDeviceAssetsFlagConfig;

  FolderSelectionScreen(this.appConfigShowDeviceAssetsFlagConfig);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Device Folders'),
          backgroundColor: Colors.black,
        ),
        body: _FoldersScreenView(this.appConfigShowDeviceAssetsFlagConfig));
  }
}

class _FoldersScreenView extends StatefulWidget {

  final AppConfig appConfigShowDeviceAssetsFlagConfig;

  _FoldersScreenView(this.appConfigShowDeviceAssetsFlagConfig);

  @override
  _FoldersScreenViewState createState() =>
      _FoldersScreenViewState();
}

class _FoldersScreenViewState
    extends State<_FoldersScreenView> {
  List<bool> _folderStatusList = [];
  List<String> _folderList = [];
  String _folders = "None";

  Future<List<AssetPathEntity>> _getDeviceFolderList() async {
    await _getFolderInfo();

    if (!await PhotoManager.requestPermission()) {
      ToastService.showError('Permission to device folders denied!');
      return Future.value([]);
    }

    final List<AssetPathEntity> folders = await PhotoManager.getAssetPathList();
    folders.sort(
        (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

    List<String> folderNameList = _folders.split(",");

    _folderStatusList = folders
        .map((asset) =>
            folderNameList.indexOf(asset.id) > -1 ? true : false)
        .toList();
    _folderList = folders.map((asset) => asset.id).toList();

    return Future.value(folders);
  }



  Future<void> _getFolderInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(widget.appConfigShowDeviceAssetsFlagConfig.configkey!);

    if (value.configValue != null) {
      _folders = value.configValue!;
    }
  }

  _updateAppConfig(int index, bool value) async {
    _folderStatusList[index] = value;

    List<String> newAutoBackupFolderList = [];
    for (int i = 0; i < _folderStatusList.length; i++) {
      if (_folderStatusList[i] == true) {
        newAutoBackupFolderList.add(_folderList[i]);
      }
    }

    _folders = newAutoBackupFolderList.join(",");

    widget.appConfigShowDeviceAssetsFlagConfig.configValue = _folders;
    
    await AppConfigResository.instance
        .saveOrUpdateConfig(widget.appConfigShowDeviceAssetsFlagConfig);

    setState(() {});
  }

  _deviceFolderList(BuildContext context, List<AssetPathEntity> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
                    padding: EdgeInsets.all(15),
                    child:Text("Selected folder from the list below will be backed up to your server")
        ),
        
        Expanded(
            child: new ListView.builder(
                itemCount: assets.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return new SwitchListTile(
                    title: Text(assets[index].name, style: TitleTextStyle),
                    secondary: const Icon(Icons.folder),
                    value: _folderStatusList[index],
                    onChanged: (bool value) {
                      _updateAppConfig(index, value);
                    },
                  );
                }))
      ],
    );
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
