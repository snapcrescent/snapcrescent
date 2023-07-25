import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapcrescent_mobile/screens/settings/folder_selection/folder_selection.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/settings_service.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class DeviceFoldersSettingsView extends StatefulWidget {
  @override
  createState() => _DeviceFoldersSettingsViewState();
}

class _DeviceFoldersSettingsViewState extends State<DeviceFoldersSettingsView> {
  bool _showDeviceAssets = false;
  String _showDeviceAssetsFolders = "None";
  


  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {
    _showDeviceAssets = await AppConfigService.instance
        .getFlag(Constants.appConfigShowDeviceAssetsFlag);
    _showDeviceAssetsFolders =
        await SettingsService.instance.getShowDeviceAssetsFolderInfo();
    
    return Future.value(true);
  }

  
  _updateShowDeviceAssetsFlag(bool value) async {
    _showDeviceAssets = value;
    await AppConfigService.instance
        .updateFlag(Constants.appConfigShowDeviceAssetsFlag, value);
    setState(() {});

    if (_showDeviceAssets) {
      _showDeviceAssetsFolders =
          await SettingsService.instance.getShowDeviceAssetsFolderInfo();

      if (_showDeviceAssetsFolders.isEmpty) {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FolderSelectionScreen(
                        Constants.appConfigShowDeviceAssetsFolders)))
            .then(onBackFromChild);
      }
    }
  }

  _settingsList(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
          title: Text("Local Library Settings"),
      ),
      ListTile(
          title: Text("Show Local Photos And Videos", style: titleTextStyle),
          subtitle:
              Text("Show photos and videos on your device on snap crescent"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.photo_album, color: Colors.teal),
          ),
          trailing: Switch(
              value: _showDeviceAssets,
              onChanged: (bool value) {
                _updateShowDeviceAssetsFlag(value);
              })),
      if (_showDeviceAssets)
        ListTile(
          title: Text("Local Folders", style: titleTextStyle),
          subtitle: Text(_showDeviceAssetsFolders.isNotEmpty
              ? _showDeviceAssetsFolders
              : "None"),
          leading: Container(
            width: 40,
            alignment: Alignment.center,
            child: const Icon(Icons.folder, color: Colors.teal),
          ),
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FolderSelectionScreen(
                            Constants.appConfigShowDeviceAssetsFolders)))
                .then(onBackFromChild);
          },
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
