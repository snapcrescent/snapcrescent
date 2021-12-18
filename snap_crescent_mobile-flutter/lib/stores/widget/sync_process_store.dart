import 'package:mobx/mobx.dart';

import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/sync_info_search_criteria.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/repository/sync_info_repository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart';

part 'sync_process_store.g.dart';

class SyncProcessStore = _SyncProcessStore with _$SyncProcessStore;

abstract class _SyncProcessStore with Store {

  @observable
  SyncProgress syncProgressState = SyncProgress.CONTACTING_SERVER;

  int? downloadedPhotoCount = 0;
  int? totalServerPhotoCount;

  int? downloadedVideoCount = 0;
  int? totalServerVideoCount;

  int? uploadedPhotoCount = 0;
  int? totalLocalPhotoCount;

  int? uploadedVideoCount = 0;
  int? totalLocalVideoCount;

  bool executionInProgress = false;

  late AssetStore photoStore;
  late AssetStore videoStore;


  @action
  Future<void> startSyncProcess() async {

    if(executionInProgress) {
      return;
    }

    executionInProgress = true;

    final localSyncInfoList = await SyncInfoService.instance.searchOnLocal();

    if (localSyncInfoList.isEmpty) {
      await _compareLocalSyncInfoWithServer(null);
    } else {
      await _compareLocalSyncInfoWithServer(localSyncInfoList.last);
    }

    syncProgressState = SyncProgress.SYNC_COMPLETED;

    executionInProgress = false;

       
  }

  _compareLocalSyncInfoWithServer(SyncInfo? localSyncInfo) async {
    try {
      bool refreshAssetStores = false;
      if(await SyncInfoService.instance.isUserLoggedIn()) {
        final serverResponse = await SyncInfoService.instance
          .search(SyncInfoSearchCriteria.defaultCriteria());

      if (serverResponse.objects!.length > 0) {
        SyncInfo serverSyncInfo = serverResponse.objects!.last;

        if (localSyncInfo == null) {
          // No local sync info is present
          // It is a first boot or app is reset
          // Need to sync everything
          await _downloadAssetsFromServer(null);
          refreshAssetStores = true;
          
        } else {
          if (localSyncInfo.lastModifiedDatetime !=
              serverSyncInfo.lastModifiedDatetime) {
            //Local sync info date is not matching with server
            await SyncInfoService.instance.deleteAllData();
            await _downloadAssetsFromServer(serverSyncInfo);
            refreshAssetStores = true;
          }
        }

      await _updateSyncInfo(serverSyncInfo);
      await _uploadAssetsToServer(serverSyncInfo);

      } else {
        // No server sync info is present
        // It is first boot of server or server is reset and it has no data
        // Empty the local sync info
        await SyncInfoService.instance.deleteAllData();
        refreshAssetStores = true;
        await _uploadAssetsToServer(null);
      }

      }
      
      if(refreshAssetStores) {
        photoStore.getAssets();     
        videoStore.getAssets();  
      }

    } catch (e) {
      print("Network error");
    } 

  }

  _downloadAssetsFromServer(SyncInfo? serverSyncInfo) async {
    await _downloadAssetsByTypeFromServer(serverSyncInfo, ASSET_TYPE.PHOTO);
    // await _downloadAssetsByTypeFromServer(serverSyncInfo, ASSET_TYPE.VIDEO);
  }

  _uploadAssetsToServer(SyncInfo? serverSyncInfo) async {
    await _uploadAssetByTypeToServer(serverSyncInfo, ASSET_TYPE.PHOTO);
    await _uploadAssetByTypeToServer(serverSyncInfo, ASSET_TYPE.VIDEO);
  }

  _downloadAssetsByTypeFromServer(
    SyncInfo? serverSyncInfo, ASSET_TYPE assetType) async {
    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.assetType = assetType.index;
    searchCriteria.resultPerPage = 1;
    searchCriteria.sortOrder = Direction.DESC;

    if(serverSyncInfo != null) {
      // searchCriteria.fromDate = serverSyncInfo.lastModifiedDatetime;
    }
    

    final photoCountResponse = await AssetService.instance.search(searchCriteria);
    final _totalAssetPhotoCount = photoCountResponse.totalResultsCount;
    
    if (assetType == ASSET_TYPE.PHOTO) {
      totalServerPhotoCount = _totalAssetPhotoCount;
    } else {
      totalServerVideoCount = _totalAssetPhotoCount;
    }

    

    if (_totalAssetPhotoCount! > 0) {
      syncProgressState = assetType == ASSET_TYPE.PHOTO
          ? SyncProgress.DOWNLOADING_PHOTO_THUMNAILS
          : SyncProgress.DOWNLOADING_VIDEO_THUMNAILS;
      

      final itemsPerBatch = 1;
      double numberOfPages = _totalAssetPhotoCount / itemsPerBatch;
      final itemsInLastBatch = _totalAssetPhotoCount % itemsPerBatch;

      if (itemsInLastBatch > 0) {
        numberOfPages++;
      }

      searchCriteria.resultPerPage = itemsPerBatch;
      searchCriteria.resultType = ResultType.SEARCH;

      int _downloadedAssetCount = 0;

      final tempSyncProgressState = syncProgressState;

      for (int pageNumber = 0; pageNumber < numberOfPages; pageNumber++) {
        searchCriteria.pageNumber = pageNumber;
        List<Asset> downloadedAssets =  await AssetService.instance.searchAndSync(searchCriteria);
        _downloadedAssetCount = pageNumber * itemsPerBatch;
        _updateDownloadedCount(assetType, _downloadedAssetCount,tempSyncProgressState);

        if(downloadedAssets.length > 0) {
          BaseUiBean bean = new BaseUiBean(
            id:1,
            version:1,
            creationDatetime:downloadedAssets.last.metadata!.creationDatetime,
            lastModifiedDatetime:downloadedAssets.last.metadata!.creationDatetime,
            active:true,
          );
          SyncInfo syncInfo = SyncInfo(
            bean : bean            );

          // await _updateSyncInfo(syncInfo);
        }        
      }

     }
  }

  _updateDownloadedCount(ASSET_TYPE assetType, _downloadedAssetCount, tempSyncProgressState) {
     syncProgressState = SyncProgress.PROCESSING;
    if (assetType == ASSET_TYPE.PHOTO) {
          downloadedPhotoCount = _downloadedAssetCount;
        } else {
          downloadedVideoCount = _downloadedAssetCount;
        }
    syncProgressState = tempSyncProgressState;
  }

  _updateSyncInfo(SyncInfo syncInfo) async{
    await SyncInfoRepository.instance.deleteAll();
    await SyncInfoRepository.instance.save(syncInfo);  
  }


  _uploadAssetByTypeToServer(SyncInfo? serverSyncInfo, ASSET_TYPE assetType) async {
    try {
      final assets = await _getAssetsSetForAutoBackUp(serverSyncInfo , 
          assetType == ASSET_TYPE.PHOTO ? AssetType.image : AssetType.video);

      syncProgressState = assetType == ASSET_TYPE.PHOTO
          ? SyncProgress.UPLOADING_PHOTOS
          : SyncProgress.UPLOADING_VIDEOS;
      
      final tempSyncProgressState = syncProgressState;
      for (final File asset in assets) {
            await AssetService.instance.save(assetType, [asset]);
            
            syncProgressState = SyncProgress.PROCESSING;
            final _totalLocalAssetCount = assets.length;
            if (assetType == ASSET_TYPE.PHOTO) {
              totalLocalPhotoCount = _totalLocalAssetCount;
              uploadedPhotoCount = uploadedPhotoCount! + 1;
            } else {
              totalLocalVideoCount = _totalLocalAssetCount;
              uploadedVideoCount = uploadedVideoCount! + 1;
            }
            syncProgressState = tempSyncProgressState;
      }
      
      

      
    } catch (e) {
      print("Network error");
    } 
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
    } 

    return assetFiles;
  }
}