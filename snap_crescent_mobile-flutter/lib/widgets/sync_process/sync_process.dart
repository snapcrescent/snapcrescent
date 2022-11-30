import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:provider/provider.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/stores/widget/sync_process_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class SyncProcessWidget extends StatefulWidget {
  @override
  SyncProcessWidgetState createState() => SyncProcessWidgetState();
}

class SyncProcessWidgetState extends State<SyncProcessWidget> {
  late SyncProcessStore _syncProcessStore;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProcessStore.startSyncProcess();
    });
  }

  _getPercentage(int? count, int? total) {
      return (count! * 100/total!).toStringAsFixed(2);
  }

  _syncProgress(SyncProgress _syncProgressState) {
    String progressLabel = "";

    if (_syncProgressState == SyncProgress.DOWNLOADING &&
        _syncProcessStore.totalServerAssetCount != 0) {
      progressLabel = '''Downloaded ${_getPercentage(_syncProcessStore.downloadedAssetCount, _syncProcessStore.totalServerAssetCount)}% items from server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING &&
        _syncProcessStore.totalLocalAssetCount != 0) {
      progressLabel =
          '''Uploaded ${_getPercentage(_syncProcessStore.uploadedAssetCount, _syncProcessStore.totalLocalAssetCount)}% items to server''';
    } else if (_syncProgressState == SyncProgress.SYNC_COMPLETED) {
      progressLabel = "";
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Row(children: <Widget>[
          Expanded(
            flex: 1,
            child: new Text(progressLabel,
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                    onPressed: () {
                      _syncProcessStore.cancelSync();
                    },
                    alignment:Alignment.topRight,
                    icon: Icon(Icons.cancel_rounded, color: Colors.white,)),
          ),
        ])),
        Container(
          height: 5,
          child: const LinearProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncProcessStore = Provider.of<SyncProcessStore>(context);
    _syncProcessStore.assetStore =  Provider.of<AssetStore>(context);

    return Observer(
        builder: (context) => _syncProcessStore.syncProgressState !=
                SyncProgress.CONTACTING_SERVER
            ? OrientationBuilder(builder: (context, orientation) {
                return _syncProgress(_syncProcessStore.syncProgressState);
              })
            : LinearProgressIndicator());
  }
}
