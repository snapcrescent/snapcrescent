

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:provider/provider.dart';
import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/stores/asset/video_store.dart';
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

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _syncProcessStore.startSyncProcess();    
    });
  }

  _syncProgress(SyncProgress _syncProgressState) {
    String progressLabel = "";

    if (_syncProgressState == SyncProgress.DOWNLOADING_PHOTO_THUMNAILS &&
        _syncProcessStore.totalServerPhotoCount != null) {
      progressLabel =
          '''Downloaded ${_syncProcessStore.downloadedPhotoCount} of ${_syncProcessStore.totalServerPhotoCount} photos from server''';
    } else if (_syncProgressState == SyncProgress.DOWNLOADING_VIDEO_THUMNAILS &&
        _syncProcessStore.totalServerVideoCount != null) {
      progressLabel =
          '''Downloaded ${_syncProcessStore.downloadedVideoCount} of ${_syncProcessStore.totalServerVideoCount} videos from server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING_PHOTOS &&
        _syncProcessStore.totalLocalPhotoCount != null) {
      progressLabel =
          '''Uploaded ${_syncProcessStore.uploadedPhotoCount} of ${_syncProcessStore.totalLocalPhotoCount} photos to server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING_VIDEOS &&
        _syncProcessStore.totalLocalVideoCount != null) {
      progressLabel =
          '''Uploaded ${_syncProcessStore.uploadedVideoCount} of ${_syncProcessStore.totalLocalVideoCount} videos to server''';
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
    _syncProcessStore = Provider.of<SyncProcessStore>(context);
    final PhotoStore _photoStore = Provider.of<PhotoStore>(context);
    final VideoStore _videoStore = Provider.of<VideoStore>(context);
    _syncProcessStore.photoStore = _photoStore;
    _syncProcessStore.videoStore = _videoStore;

    return Observer(
        builder: (context) => _syncProcessStore.syncProgressState != SyncProgress.CONTACTING_SERVER
                ? OrientationBuilder(builder: (context, orientation) {
                    return _syncProgress(_syncProcessStore.syncProgressState);
                  })
                : LinearProgressIndicator()
              );
  }
}
