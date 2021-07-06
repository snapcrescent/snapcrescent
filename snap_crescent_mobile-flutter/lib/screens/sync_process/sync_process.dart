import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/photo_search_criteria.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/sync_info_search_criteria.dart';
import 'package:snap_crescent/models/video_search_criteria.dart';
import 'package:snap_crescent/resository/sync_info_resository.dart';
import 'package:snap_crescent/screens/photo_grid/photo_grid.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/services/video_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class SyncProcessScreen extends StatelessWidget {
  static const routeName = '/sync_process';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[Expanded(child: _SyncProcessView())],
    ));
  }
}

class _SyncProcessView extends StatefulWidget {
  @override
  _SyncProcessViewState createState() => _SyncProcessViewState();
}

class _SyncProcessViewState extends State<_SyncProcessView> {
  @observable
  int? _syncProgressState = 1;

  int? _syncedPhotoCount = 0;
  int? _totalPhotoCount;

  int? _syncedVideoCount = 0;
  int? _totalVideoCount;

  _navigateToPhotoGrid() {
    Timer(
        Duration(seconds: 2),
        () =>
            Navigator.pushReplacementNamed(context, PhotoGridScreen.routeName));
  }

  _syncPhotosFromServer(SyncInfo serverSyncInfo) async {
    _syncProgressState = 1;

    setState(() {});

    PhotoSearchCriteria searchCriteria = PhotoSearchCriteria.defaultCriteria();

    searchCriteria.resultPerPage = 1;
    searchCriteria.resultType = ResultType.OPTION;

    final photoCountResponse = await PhotoService().search(searchCriteria);
    _totalPhotoCount = photoCountResponse.totalResultsCount;

    setState(() {});

    final itemsPerBatch = 1;
    final numberOfPages = _totalPhotoCount! / itemsPerBatch;
    final itemsInLastBatch = _totalPhotoCount! % itemsPerBatch;

    searchCriteria.resultPerPage = itemsPerBatch;
    searchCriteria.resultType = ResultType.SEARCH;

    for (int pageNumber = 0; pageNumber < numberOfPages; pageNumber++) {
      searchCriteria.pageNumber = pageNumber;
      await PhotoService().searchAndSync(searchCriteria);
      _syncedPhotoCount = pageNumber * itemsPerBatch;

      setState(() {});
    }

    if (itemsInLastBatch > 0) {
      searchCriteria.pageNumber = searchCriteria.pageNumber! + 1;
      searchCriteria.resultPerPage = itemsInLastBatch;
      await PhotoService().searchAndSync(searchCriteria);
      _syncedPhotoCount = _syncedPhotoCount! + itemsInLastBatch;

      setState(() {});
    }
  }

  _syncVideosFromServer(SyncInfo serverSyncInfo) async {
    _syncProgressState = 2;

    setState(() {});

    VideoSearchCriteria searchCriteria = VideoSearchCriteria.defaultCriteria();

    searchCriteria.resultPerPage = 1;
    searchCriteria.resultType = ResultType.OPTION;

    final videoCountResponse = await VideoService().search(searchCriteria);
    _totalVideoCount = videoCountResponse.totalResultsCount;

    setState(() {});

    final itemsPerBatch = 1;
    final numberOfPages = _totalVideoCount! / itemsPerBatch;
    final itemsInLastBatch = _totalVideoCount! % itemsPerBatch;

    searchCriteria.resultPerPage = itemsPerBatch;
    searchCriteria.resultType = ResultType.SEARCH;

    for (int pageNumber = 0; pageNumber < numberOfPages; pageNumber++) {
      searchCriteria.pageNumber = pageNumber;
      await VideoService().searchAndSync(searchCriteria);
      _syncedVideoCount = pageNumber * itemsPerBatch;

      setState(() {});
    }

    if (itemsInLastBatch > 0) {
      searchCriteria.pageNumber = searchCriteria.pageNumber! + 1;
      searchCriteria.resultPerPage = itemsInLastBatch;
      await VideoService().searchAndSync(searchCriteria);
      _syncedVideoCount = _syncedPhotoCount! + itemsInLastBatch;

      setState(() {});
    }
  }

  _syncLocalSyncInfoFromServer(SyncInfo serverSyncInfo) async {
    await _syncPhotosFromServer(serverSyncInfo);
    await _syncVideosFromServer(serverSyncInfo);

    await SyncInfoResository.instance.save(serverSyncInfo);

    _syncProgressState = 3;

    setState(() {});

    _navigateToPhotoGrid();
  }

  _compareLocalSyncInfoWithServer(SyncInfo? localSyncInfo) async {
    final serverResponse = await SyncInfoService()
        .search(SyncInfoSearchCriteria.defaultCriteria());

    if (serverResponse.objects!.length > 0) {
      SyncInfo serverSyncInfo = serverResponse.objects!.last;

      if (localSyncInfo == null) {
        // No local sync info is present
        // It is a first boot or app is reset
        // Need to sync everything
        _syncLocalSyncInfoFromServer(serverSyncInfo);
      } else {
        if (localSyncInfo.lastModifiedDatetime !=
            serverSyncInfo.lastModifiedDatetime) {
          await SyncInfoService().deleteAllData();
          _syncLocalSyncInfoFromServer(serverSyncInfo);

          //Local sync info date is not matching with server

        } else {
          // Local sync info date is matching with server
          // Everything is in sync
          _navigateToPhotoGrid();
        }
      }
    } else {
      // No server sync info is present
      // It is first boot of server or server is reset and it has no data
      // Empty the local sync info and Send user directly to photo grid
      await SyncInfoService().deleteAllData();

      _navigateToPhotoGrid();
    }
  }

  _syncProcess() {
    String progressLabel = "Checking server for out of sync data";

    if (_syncProgressState == 1 && _totalPhotoCount != null) {
      progressLabel =
          '''Synced $_syncedPhotoCount of $_totalPhotoCount photos from server''';
    } else if (_syncProgressState == 2 && _totalVideoCount != null) {
      progressLabel =
          '''Synced $_syncedVideoCount of $_totalVideoCount videos from server''';
    } else if (_syncProgressState == 3) {
      progressLabel = "Sync completed";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: new Text(progressLabel),
          ),
          Container(
            padding: EdgeInsets.all(10),
            width: 60,
            height: 60,
            child: const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    SyncInfoService().searchOnLocal().then((localSyncInfoList) => {
          if (localSyncInfoList.isEmpty)
            {_compareLocalSyncInfoWithServer(null)}
          else
            {_compareLocalSyncInfoWithServer(localSyncInfoList.last)}
        });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (context) => _syncProgressState != 0
            ? OrientationBuilder(builder: (context, orientation) {
                return _syncProcess();
              })
            : Center(
                child: Container(
                  width: 60,
                  height: 60,
                  child: const CircularProgressIndicator(),
                ),
              ));
  }
}
