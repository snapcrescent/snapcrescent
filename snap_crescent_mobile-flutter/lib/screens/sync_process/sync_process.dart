import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/sync_info_search_criteria.dart';
import 'package:snap_crescent/resository/sync_info_resository.dart';
import 'package:snap_crescent/screens/cloud/grid/assets_grid.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/stores/local_photo_store.dart';
import 'package:snap_crescent/stores/local_video_store.dart';
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
  int _syncProgressState = 1;

  int? _syncedPhotoCount = 0;
  int? _totalPhotoCount;

  int? _syncedVideoCount = 0;
  int? _totalVideoCount;

  _navigateToPhotoGrid() {
    Timer(
        Duration(seconds: 2),
        () =>
            Navigator.pushReplacementNamed(context, AssetsGridScreen.routeName, arguments: ASSET_TYPE.PHOTO));
  }

  _syncPhotosFromServer(SyncInfo serverSyncInfo) async {
    _syncProgressState = 1;

    setState(() {});

    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.assetType = ASSET_TYPE.PHOTO.index;
    searchCriteria.resultPerPage = 1;

    final photoCountResponse = await AssetService().search(searchCriteria);
    _totalPhotoCount = photoCountResponse.totalResultsCount;

    setState(() {});

    final itemsPerBatch = 1;
    final numberOfPages = _totalPhotoCount! / itemsPerBatch;
    final itemsInLastBatch = _totalPhotoCount! % itemsPerBatch;

    searchCriteria.resultPerPage = itemsPerBatch;
    searchCriteria.resultType = ResultType.SEARCH;

    for (int pageNumber = 0; pageNumber < numberOfPages; pageNumber++) {
      searchCriteria.pageNumber = pageNumber;
      await AssetService().searchAndSync(searchCriteria);
      _syncedPhotoCount = pageNumber * itemsPerBatch;

      setState(() {});
    }

    if (itemsInLastBatch > 0) {
      searchCriteria.pageNumber = searchCriteria.pageNumber! + 1;
      searchCriteria.resultPerPage = itemsInLastBatch;
      await AssetService().searchAndSync(searchCriteria);
      _syncedPhotoCount = _syncedPhotoCount! + itemsInLastBatch;

      setState(() {});
    }
  }

  _syncVideosFromServer(SyncInfo serverSyncInfo) async {
    _syncProgressState = 2;

    setState(() {});

    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();

     searchCriteria.assetType = ASSET_TYPE.VIDEO.index;
    searchCriteria.resultPerPage = 1;
    searchCriteria.resultType = ResultType.OPTION;

    final videoCountResponse = await AssetService().search(searchCriteria);
    _totalVideoCount = videoCountResponse.totalResultsCount;

    setState(() {});

    final itemsPerBatch = 1;
    final numberOfPages = _totalVideoCount! / itemsPerBatch;
    final itemsInLastBatch = _totalVideoCount! % itemsPerBatch;

    searchCriteria.resultPerPage = itemsPerBatch;
    searchCriteria.resultType = ResultType.SEARCH;

    for (int pageNumber = 0; pageNumber < numberOfPages; pageNumber++) {
      searchCriteria.pageNumber = pageNumber;
      await AssetService().searchAndSync(searchCriteria);
      _syncedVideoCount = pageNumber * itemsPerBatch;

      setState(() {});
    }

    if (itemsInLastBatch > 0) {
      searchCriteria.pageNumber = searchCriteria.pageNumber! + 1;
      searchCriteria.resultPerPage = itemsInLastBatch;
      await AssetService().searchAndSync(searchCriteria);
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
    try {
      final serverResponse = await SyncInfoService()
          .search(SyncInfoSearchCriteria.defaultCriteria());

      if (serverResponse.objects!.length > 0) {
        SyncInfo serverSyncInfo = serverResponse.objects!.last;

        if (localSyncInfo == null) {
          // No local sync info is present
          // It is a first boot or app is reset
          // Need to sync everything
          await _syncLocalSyncInfoFromServer(serverSyncInfo);
        } else {
          if (localSyncInfo.lastModifiedDatetime !=
              serverSyncInfo.lastModifiedDatetime) {
            //Local sync info date is not matching with server
            await SyncInfoService().deleteAllData();
            await _syncLocalSyncInfoFromServer(serverSyncInfo);
          } 
        }
      } else {
        // No server sync info is present
        // It is first boot of server or server is reset and it has no data
        // Empty the local sync info and Send user directly to photo grid
        await SyncInfoService().deleteAllData();
      }
    } catch (e) {
      print("Network error");
    } finally {
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
    
    final LocalPhotoStore photosStore = Provider.of<LocalPhotoStore>(context);
    final LocalVideoStore videosStore = Provider.of<LocalVideoStore>(context);

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
