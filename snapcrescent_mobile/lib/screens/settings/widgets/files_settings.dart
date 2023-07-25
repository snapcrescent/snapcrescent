import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/metadata_service.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';
import 'package:snapcrescent_mobile/style.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class FilesSettingsView extends StatefulWidget {
  @override
  createState() => _FilesSettingsViewState();
}

class _FilesSettingsViewState extends State<FilesSettingsView> {

  String _lastSyncActivityDate = "Never";
  int _downloadedAssetCount = 0;

  String _uploadedAssetSize = "";
  int _uploadedAssetCount = 0;

  late AssetStore _assetStore;
  
  
  FutureOr onBackFromChild(dynamic value) {
    _getSettingsData();
    setState(() {});
  }

  Future<bool> _getSettingsData() async {

    String? lastSyncActivityTimestamp = await AppConfigService.instance.getConfig(Constants.appConfigLastSyncActivityTimestamp);
    String defaultLastSyncActivityTimestamp = DateUtilities().formatDate(Constants.defaultLastSyncActivityTimestamp, DateUtilities.timeStampFormat);

    if(lastSyncActivityTimestamp != null && lastSyncActivityTimestamp != defaultLastSyncActivityTimestamp) {
      _lastSyncActivityDate = lastSyncActivityTimestamp;
    }

    _downloadedAssetCount = await AssetService().countOnLocal();

    _uploadedAssetCount = await MetadataService().countByLocalAssetIdNotNull();

    double sizeInBytes = (await MetadataService().sizeByLocalAssetIdNotNull()).toDouble();
    _uploadedAssetSize = _convertToHigherSize(sizeInBytes, 0);

    //Convert bytes to higher units
    
    return Future.value(true);
  }

  String _convertToHigherSize(double size, int iteration) {
    if(size < 1024) {
      String suffix = "";
      switch(iteration){
        case 0 : suffix = "Bytes";  break;
        case 1 : suffix = "KB"; break;
        case 2 : suffix = "MB"; break;
        case 3 : suffix = "GB"; break;
      }
      return size.toStringAsFixed(1) + suffix;
    } else {
      return _convertToHigherSize(size / 1024, iteration + 1);
    }
  }

    _showDownloadsClearConfirmationDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you want to delete all downloaded photos and videos from this device?'),
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
    await AssetService().deleteAllData();
    await _assetStore.refreshStore();
    _lastSyncActivityDate = "Never";
    await AppConfigService.instance.updateDateConfig(Constants.appConfigLastSyncActivityTimestamp, Constants.defaultLastSyncActivityTimestamp, DateUtilities.timeStampFormat);
    ToastService.showSuccess("Successfully deleted downloaded data.");
    setState(() {});
    Navigator.pop(context);
  }

  _showFreeUpDeviceConfirmationDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Do you want to delete all backed up photos and videos from this device?'),
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
                _freeUpDevice();
              },
            )
          ],
        );
      },
    );
  }

  _freeUpDevice() async {
    await AssetService().deleteUploadedAssets();
    await _assetStore.refreshStore();
    ToastService.showSuccess("Successfully deleted uploaded photos and videos.");
    setState(() {});
    Navigator.pop(context);
  }


  _settingsList(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero, children: <Widget>[
      ListTile(
          title: Text("File Info"),
      ),
      ListTile(
        title: Text("Downloaded Photos and Videos", style: titleTextStyle),
        subtitle: Text("Last Download: ${_lastSyncActivityDate.isEmpty ? "Never" : _lastSyncActivityDate}\nTotal Pictures and Videos: $_downloadedAssetCount"),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.delete, color: Colors.teal),
        ),
        onTap: () {
          _showDownloadsClearConfirmationDialog();
        },
      ),
      ListTile(
        title: Text("Free Up Space", style: titleTextStyle),
        subtitle: Text("${_uploadedAssetCount > 0 ? ("Size $_uploadedAssetSize\n") : ""}Backed up Pictures and Videos: $_uploadedAssetCount"),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: const Icon(Icons.delete, color: Colors.teal),
        ),
        onTap: () {
          _showFreeUpDeviceConfirmationDialog();
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

     _assetStore = Provider.of<AssetStore>(context);

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
