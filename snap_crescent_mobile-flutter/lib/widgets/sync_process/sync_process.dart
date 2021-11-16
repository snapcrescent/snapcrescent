import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/sync_info_search_criteria.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/repository/sync_info_repository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/stores/cloud/asset_store.dart';
import 'package:snap_crescent/stores/cloud/photo_store.dart';
import 'package:snap_crescent/stores/cloud/video_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class SyncProcessWidget extends StatefulWidget {
  @override
  _SyncProcessWidgetState createState() => _SyncProcessWidgetState();
}

class _SyncProcessWidgetState extends State<SyncProcessWidget> {
  AssetStore? _photoStore;
  AssetStore? _videoStore;

  @observable
  SyncProgress _syncProgressState = SyncProgress.CONTACTING_SERVER;

  int? _downloadedPhotoCount = 0;
  int? _totalServerPhotoCount;

  int? _downloadedVideoCount = 0;
  int? _totalServerVideoCount;

  int? _uploadedPhotoCount = 0;
  int? _totalLocalPhotoCount;

  int? _uploadedVideoCount = 0;
  int? _totalLocalVideoCount;

  @override
  void initState() {
    super.initState();

    SyncInfoService().searchOnLocal().then((localSyncInfoList) => {
          if (localSyncInfoList.isEmpty)
            {_compareLocalSyncInfoWithServer(null)}
          else
            {_compareLocalSyncInfoWithServer(localSyncInfoList.last)},
        });
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
          await _downloadAssetsFromServer(serverSyncInfo);
        } else {
          if (localSyncInfo.lastModifiedDatetime !=
              serverSyncInfo.lastModifiedDatetime) {
            //Local sync info date is not matching with server
            await SyncInfoService().deleteAllData();
            await _downloadAssetsFromServer(serverSyncInfo);
          }
        }

      await _uploadAssetsToServer(serverSyncInfo);

      } else {
        // No server sync info is present
        // It is first boot of server or server is reset and it has no data
        // Empty the local sync info
        await SyncInfoService().deleteAllData();
        await _uploadAssetsToServer(null);
      }

    //await refreshAssetStores();

      
    } catch (e) {
      print("Network error");
    } finally {
      Timer(
                      Duration(seconds: 2),
                      () => {
                        _syncProgressState = SyncProgress.SYNC_COMPLETED,
                        setState(() {})
                      });
      
    }
  }

  refreshAssetStores() async {
    await _photoStore!.getAssets(true);
    await _videoStore!.getAssets(true);
  }

  _downloadAssetsFromServer(SyncInfo serverSyncInfo) async {
    await _downloadAssetsByTypeFromServer(serverSyncInfo, ASSET_TYPE.PHOTO);
    await _downloadAssetsByTypeFromServer(serverSyncInfo, ASSET_TYPE.VIDEO);
    await SyncInfoRepository.instance.save(serverSyncInfo);
  }

  _uploadAssetsToServer(SyncInfo? serverSyncInfo) async {
    await _uploadAssetByTypeToServer(serverSyncInfo, ASSET_TYPE.PHOTO);
    await _uploadAssetByTypeToServer(serverSyncInfo, ASSET_TYPE.VIDEO);
  }

  _downloadAssetsByTypeFromServer(
      SyncInfo serverSyncInfo, ASSET_TYPE assetType) async {
    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.assetType = assetType.index;
    searchCriteria.resultPerPage = 1;
    searchCriteria.fromDate = serverSyncInfo.lastModifiedDatetime;

    final photoCountResponse = await AssetService().search(searchCriteria);
    final _totalAssetPhotoCount = photoCountResponse.totalResultsCount;

    if (assetType == ASSET_TYPE.PHOTO) {
      _totalServerPhotoCount = _totalAssetPhotoCount;
    } else {
      _totalServerVideoCount = _totalAssetPhotoCount;
    }

    if (_totalAssetPhotoCount! > 0) {
      _syncProgressState = assetType == ASSET_TYPE.PHOTO
          ? SyncProgress.DOWNLOADING_PHOTO_THUMNAILS
          : SyncProgress.DOWNLOADING_VIDEO_THUMNAILS;
      setState(() {});

      final itemsPerBatch = 1;
      final numberOfPages = _totalAssetPhotoCount / itemsPerBatch;
      final itemsInLastBatch = _totalAssetPhotoCount % itemsPerBatch;

      searchCriteria.resultPerPage = itemsPerBatch;
      searchCriteria.resultType = ResultType.SEARCH;

      int _downloadedAssetCount = 0;

      for (int pageNumber = 0; pageNumber < numberOfPages; pageNumber++) {
        searchCriteria.pageNumber = pageNumber;
        await AssetService().searchAndSync(searchCriteria);
        _downloadedAssetCount = pageNumber * itemsPerBatch;

        if (assetType == ASSET_TYPE.PHOTO) {
          _downloadedPhotoCount = _downloadedAssetCount;
        } else {
          _downloadedVideoCount = _downloadedAssetCount;
        }

        setState(() {});
      }

      if (itemsInLastBatch > 0) {
        searchCriteria.pageNumber = searchCriteria.pageNumber! + 1;
        searchCriteria.resultPerPage = itemsInLastBatch;
        await AssetService().searchAndSync(searchCriteria);
        _downloadedAssetCount = _downloadedAssetCount + itemsInLastBatch;

        if (assetType == ASSET_TYPE.PHOTO) {
          _downloadedPhotoCount = _downloadedAssetCount;
        } else {
          _downloadedVideoCount = _downloadedAssetCount;
        }

        setState(() {});
      }
    }
  }

  _uploadAssetByTypeToServer(SyncInfo? serverSyncInfo, ASSET_TYPE assetType) async {
    try {
      final assets = await _getAssetsSetForAutoBackUp(serverSyncInfo , 
          assetType == ASSET_TYPE.PHOTO ? AssetType.image : AssetType.video);

      _syncProgressState = assetType == ASSET_TYPE.PHOTO
          ? SyncProgress.UPLOADING_PHOTOS
          : SyncProgress.UPLOADING_VIDEOS;
      
      for (final File asset in assets) {
            await AssetService().save(assetType, [asset]);

            final _totalLocalAssetCount = assets.length;
            if (assetType == ASSET_TYPE.PHOTO) {
              _totalLocalPhotoCount = _totalLocalAssetCount;
              _uploadedPhotoCount = _uploadedPhotoCount! + 1;
            } else {
              _totalLocalVideoCount = _totalLocalAssetCount;
              _uploadedVideoCount = _uploadedVideoCount! + 1;
            }

            setState(() {});
      }
      
      

      
    } catch (e) {
      print("Network error");
    } finally {}
  }

  _getAssetsSetForAutoBackUp(SyncInfo? serverSyncInfo, AssetType assetType) async {
    List<File> assetFiles = [];

    try {
      AppConfig value = await AppConfigRepository.instance
          .findByKey(Constants.appConfigAutoBackupFolders);

      if (value.configValue != null) {
        final List<AssetPathEntity> folders =
            await PhotoManager.getAssetPathList();
        folders.sort(
            (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

        List<String> autoBackupFolderNameList = value.configValue!.split(",");
        List<AssetPathEntity> autoBackupFolders = [];

        for (int i = 0; i < folders.length; i++) {
          if (autoBackupFolderNameList.indexOf(folders[i].id) > -1) {
            autoBackupFolders.add(folders[i]);
          }
        }

        for (int i = 0; i < autoBackupFolders.length; i++) {
          AssetPathEntity folder = autoBackupFolders[i];

          final allAssets = await folder.getAssetListRange(
            start: 0, // start at index 0
            end: 100000, // end at a very big index (to get all the assets)
          );

          final targetAssets = allAssets.where((asset) => asset.type == assetType);

          final filteredAssetsByDate = []; 

          if(serverSyncInfo == null) {
            filteredAssetsByDate.addAll(targetAssets);
          } else{
            filteredAssetsByDate.addAll(targetAssets.where((asset) => (asset.createDtSecond! * 1000) > serverSyncInfo.lastModifiedDatetime!.millisecondsSinceEpoch));
          }
          
          for (final AssetEntity asset in filteredAssetsByDate) {
            final File? assetFile = await asset.file;
            assetFiles.add(assetFile!);
          }
        }
      }
    } catch (e) {
      print("Network error");
    } finally {}

    return assetFiles;
  }

  _syncProgress() {
    String progressLabel = "";

    if (_syncProgressState == SyncProgress.DOWNLOADING_PHOTO_THUMNAILS &&
        _totalServerPhotoCount != null) {
      progressLabel =
          '''Downloaded $_downloadedPhotoCount of $_totalServerPhotoCount photos from server''';
    } else if (_syncProgressState == SyncProgress.DOWNLOADING_VIDEO_THUMNAILS &&
        _totalServerVideoCount != null) {
      progressLabel =
          '''Downloaded $_downloadedVideoCount of $_totalServerVideoCount videos from server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING_PHOTOS &&
        _totalLocalPhotoCount != null) {
      progressLabel =
          '''Uploaded $_uploadedPhotoCount of $_totalLocalPhotoCount photos to server''';
    } else if (_syncProgressState == SyncProgress.UPLOADING_VIDEOS &&
        _totalLocalVideoCount != null) {
      progressLabel =
          '''Uploaded $_uploadedVideoCount of $_totalLocalVideoCount videos to server''';
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
    _photoStore = Provider.of<PhotoStore>(context);
    _videoStore = Provider.of<VideoStore>(context);

    return Observer(
        builder: (context) =>
            _syncProgressState != SyncProgress.CONTACTING_SERVER
                ? OrientationBuilder(builder: (context, orientation) {
                    return _syncProgress();
                  })
                : Container(
                    height: 5,
                    child: const LinearProgressIndicator(),
                  ));
  }
}
