import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:provider/provider.dart';
import 'package:snap_crescent/services/global_service.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/stores/widget/sync_process_store.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:workmanager/workmanager.dart';

class SyncProcessWidget extends StatefulWidget {
  @override
  SyncProcessWidgetState createState() => SyncProcessWidgetState();
}

class SyncProcessWidgetState extends State<SyncProcessWidget> {
  late SyncProcessStore _syncProcessStore;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProcessStore.startSyncProcess();
      timer = Timer.periodic(Duration(seconds: 60),
          (Timer t) => _syncProcessStore.startSyncProcess());
    });

    Workmanager().registerPeriodicTask("SnapCrescent-Asset-Sync", "Asset-Sync", frequency: Duration(minutes: 15));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _getPercentage(int? count, int? total) {
    return (count! * 100 / total!).toStringAsFixed(2);
  }

  _syncProgress(SyncProgress _syncProgressState) {
    String progressLabel = "";

    if (_syncProgressState == SyncProgress.DOWNLOADING &&
        _syncProcessStore.totalServerAssetCount != 0) {
      progressLabel =
          '''Downloading (${_getPercentage(_syncProcessStore.downloadedAssetCount, _syncProcessStore.totalServerAssetCount)}%)''';
    } else if (_syncProgressState == SyncProgress.UPLOADING &&
        _syncProcessStore.totalLocalAssetCount != 0) {
      progressLabel =
          '''Uploading (${_getPercentage(_syncProcessStore.uploadedAssetCount, _syncProcessStore.totalLocalAssetCount)}%)''';
    } else if (_syncProgressState == SyncProgress.PROCESSING) {
      
    } else {
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (progressLabel.isNotEmpty)
          Text(progressLabel,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              )),
        Container(
          height: 2,
          child: const LinearProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncProcessStore = Provider.of<SyncProcessStore>(context);
    _syncProcessStore.assetStore = Provider.of<AssetStore>(context);

    GlobalService.instance.syncProcessStore = _syncProcessStore;

    return Observer(
        builder: (context) => _syncProcessStore.syncProgressState !=
                SyncProgress.CONTACTING_SERVER
            ? _syncProgress(_syncProcessStore.syncProgressState)
            : LinearProgressIndicator());
  }
}
