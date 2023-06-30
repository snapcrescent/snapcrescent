import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/style.dart';

class FolderSelectionScreen extends StatelessWidget {
  static const routeName = '/folder_selection';

  final String appConfigKey;

  FolderSelectionScreen(this.appConfigKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Device Folders'),
          backgroundColor: Colors.black,
        ),
        body: _FoldersScreenView(this.appConfigKey));
  }
}

class _FoldersScreenView extends StatefulWidget {
  final String appConfigKey;

  _FoldersScreenView(this.appConfigKey);

  @override
  _FoldersScreenViewState createState() => _FoldersScreenViewState();
}

class _FoldersScreenViewState extends State<_FoldersScreenView> {
  List<bool> _folderStatusList = [];
  List<String> _folderList = [];
  String _folders = "None";

  Future<List<AssetPathEntity>> _getDeviceFolderList() async {
    await _getFolderInfo();
  
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();

    if (!_ps.isAuth) {
      ToastService.showError('Permission to device folders denied!');
      Navigator.pop(context);
      return Future.value([]);
    }

    final List<AssetPathEntity> folders = await PhotoManager.getAssetPathList();
    folders.sort(
        (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

    List<String> folderNameList = _folders.split(",");

    _folderStatusList = folders
        .map((asset) => folderNameList.indexOf(asset.id) > -1 ? true : false)
        .toList();
    _folderList = folders.map((asset) => asset.id).toList();

    return Future.value(folders);
  }

  Future<void> _getFolderInfo() async {
    String? value = await AppConfigService.instance.getConfig(widget.appConfigKey);
    
    if (value != null) {
      _folders = value;
    }
  }

  _updateAppConfig(int index, bool value) async {
    _folderStatusList[index] = value;

    List<String> newFolderList = [];
    for (int i = 0; i < _folderStatusList.length; i++) {
      if (_folderStatusList[i] == true) {
        newFolderList.add(_folderList[i]);
      }
    }

    _folders = newFolderList.join(",");
    
    await AppConfigService.instance.updateConfig(widget.appConfigKey, _folders);

    setState(() {});
  }

  _deviceFolderList(BuildContext context, List<AssetPathEntity> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(15),
            child: Text(
                "Selected folder from the list below")),
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
