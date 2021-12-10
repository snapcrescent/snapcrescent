

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:provider/provider.dart';

import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/stores/asset/video_store.dart';
import 'package:snap_crescent/stores/widget/sync_process_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class SyncProcessWidget extends StatefulWidget {
  @override
  _SyncProcessWidgetState createState() => _SyncProcessWidgetState();
}

class _SyncProcessWidgetState extends State<SyncProcessWidget> {
  SyncProcessStore syncProcessStore = new SyncProcessStore();
  
  @override
  void initState() {
    super.initState();
    syncProcessStore.startSyncProcess();
  }

  _syncProgress(SyncProgress _syncProgressState) {
    String progressLabel = "";

    if (_syncProgressState == SyncProgress.DOWNLOADING_PHOTO_THUMNAILS &&
        syncProcessStore.totalServerPhotoCount != null) {
      progressLabel =
          '''Downloaded ${syncProcessStore.downloadedPhotoCount} of ${syncProcessStore.totalServerPhotoCount} photos from server''';
    } else if (_syncProgressState == SyncProgress.DOWNLOADING_VIDEO_THUMNAILS &&
        syncProcessStore.totalServerVideoCount != null) {
      progressLabel =
          '''Downloaded ${syncProcessStore.downloadedVideoCount} of ${syncProcessStore.totalServerVideoCount} videos from server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING_PHOTOS &&
        syncProcessStore.totalLocalPhotoCount != null) {
      progressLabel =
          '''Uploaded ${syncProcessStore.uploadedPhotoCount} of ${syncProcessStore.totalLocalPhotoCount} photos to server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING_VIDEOS &&
        syncProcessStore.totalLocalVideoCount != null) {
      progressLabel =
          '''Uploaded ${syncProcessStore.uploadedVideoCount} of ${syncProcessStore.totalLocalVideoCount} videos to server''';
    } else if (_syncProgressState == SyncProgress.SYNC_COMPLETED) {
      progressLabel = "";
      return Container();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: new Text(progressLabel,
              style: TextStyle(
                color: Colors.white,
              )),
        ),
        Container(
          height: 5,
          child: const LinearProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _photoStore = Provider.of<PhotoStore>(context);
    final _videoStore = Provider.of<VideoStore>(context);

    syncProcessStore.setAssetStore(_photoStore, _videoStore);

    return Observer(
        builder: (context) => syncProcessStore.syncProgressState != SyncProgress.CONTACTING_SERVER
                ? OrientationBuilder(builder: (context, orientation) {
                    return _syncProgress(syncProcessStore.syncProgressState);
                  })
                : LinearProgressIndicator()
              );
  }
}
