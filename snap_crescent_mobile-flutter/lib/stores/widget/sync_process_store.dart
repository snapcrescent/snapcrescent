import 'dart:async';

import 'package:mobx/mobx.dart';

import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/metadata_service.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';
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
    
    await _startSyncProcessForAsset(AppAssetType.PHOTO);
    await _startSyncProcessForAsset(AppAssetType.VIDEO);

    executionInProgress = false;
  }

  cancelSync() {
    executionInProgress = false;
    AssetService.instance.cancelSyncProcess();
  }

  _startSyncProcessForAsset(AppAssetType assetType) async {
    try {
      AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
          assetSearchCriteria.assetType = assetType.id;
          assetSearchCriteria.resultPerPage = 1;

          final assetCount = await AssetService.instance.countOnLocal(assetSearchCriteria);
          final latestAssetsList = await AssetService.instance.searchOnLocal(assetSearchCriteria);
          
          if (assetCount == 0) {
            await _compareLatestLocalAssetDateWithServer(null, assetType);
          } else {
              Asset latestAsset = latestAssetsList.first;
              final thumbnail = await ThumbnailService.instance.findByIdOnLocal(latestAsset.thumbnailId!);
              latestAsset.thumbnail = thumbnail;

              final metadata = await MetadataService.instance.findByIdOnLocal(latestAsset.metadataId!);
              latestAsset.metadata = metadata;

            await _compareLatestLocalAssetDateWithServer(latestAsset.metadata!.creationDateTime!, assetType);
          }

          syncProgressState = SyncProgress.SYNC_COMPLETED;

        } catch (ex) {
          throw Exception(ex.toString());
        }
  }

  
  _compareLatestLocalAssetDateWithServer(DateTime? latestAssetDate, AppAssetType assetType) async {
    try {
      bool refreshAssetStores = false;
      if(await AssetService.instance.isUserLoggedIn()) {
        
        AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
        assetSearchCriteria.resultPerPage = 1 ;
        final serverAssetResponse = await AssetService.instance.search(assetSearchCriteria);

      if (serverAssetResponse.totalResultsCount! > 0) {
        DateTime latestServerAssetDate = serverAssetResponse.objects!.last.metadata!.creationDateTime!;

        if (latestAssetDate == null) {
          // No local sync info is present
          // It is a first boot or app is reset
          // Need to sync everything
          await _downloadAssetsFromServer(null, assetType);
          refreshAssetStores = true;
          
        } else {

          
          if (latestServerAssetDate != latestAssetDate) {
            //Local latest asset date is not matching with server's latest asset
            await _downloadAssetsFromServer(latestAssetDate, assetType);
            refreshAssetStores = true;
          } 
          
          final newAssetCount = await AssetService.instance.countOnLocal(assetSearchCriteria);
          if(serverAssetResponse.totalResultsCount! < newAssetCount) {
            //Server has less records than app, means some server items are deleted
            AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
            assetSearchCriteria.assetType = assetType.id;
            await AssetService.instance.searchAndSyncInactiveRecords(assetSearchCriteria);
          }
          
          
        }

      await _uploadAssetsToServer(latestAssetDate, assetType);

      } else {
        // No server sync info is present
        // It is first boot of server or server is reset and it has no data
        // Empty the local sync info
        await AssetService.instance.deleteAllData();
        refreshAssetStores = true;
        await _uploadAssetsToServer(null, assetType);
      }

      }
      
      if(refreshAssetStores) {
        photoStore.loadMoreAssets(0);     
        videoStore.loadMoreAssets(0);  
      }

    } catch (e) {
      print("Network error");
    } 

  }

  _downloadAssetsFromServer(DateTime? latestAssetDate, AppAssetType assetType) async {
    await _downloadAssetsByTypeFromServer(latestAssetDate, assetType);
  }

  _uploadAssetsToServer(DateTime? latestAssetDate, AppAssetType assetType) async {
    await _uploadAssetByTypeToServer(latestAssetDate, assetType);
  }

  _downloadAssetsByTypeFromServer(
    DateTime? latestAssetDate, AppAssetType assetType) async {

    if(!executionInProgress) {
      return;
    }

    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.assetType = assetType.id;
    searchCriteria.resultPerPage = 1;
    searchCriteria.sortOrder = Direction.DESC;

    if(latestAssetDate != null) {
        searchCriteria.fromDate = latestAssetDate;
    }
    

    final assetCountResponse = await AssetService.instance.search(searchCriteria);
    final _totalAssetCount = assetCountResponse.totalResultsCount;
    
    if (assetType == AppAssetType.PHOTO) {
      totalServerPhotoCount = _totalAssetCount;
    } else {
      totalServerVideoCount = _totalAssetCount;
    }

    if (_totalAssetCount! > 0) {
      syncProgressState = assetType == AppAssetType.PHOTO
          ? SyncProgress.DOWNLOADING_PHOTO_THUMBNAILS
          : SyncProgress.DOWNLOADING_VIDEO_THUMBNAILS;
      

      searchCriteria.pageNumber = 0;
      searchCriteria.resultPerPage = _totalAssetCount;
      searchCriteria.resultType = ResultType.SEARCH;

      
      final tempSyncProgressState = syncProgressState;

       await AssetService.instance.searchAndSync(searchCriteria,(downloadedAssetCount) {
            _updateDownloadedCount(assetType, downloadedAssetCount,tempSyncProgressState);
        }); 
     }
  }

  _updateDownloadedCount(AppAssetType assetType, _downloadedAssetCount, tempSyncProgressState) {
     syncProgressState = SyncProgress.PROCESSING;
    if (assetType == AppAssetType.PHOTO) {
          if(_downloadedAssetCount % 100 == 0) {
            photoStore.loadMoreAssets(0);     
          }
          
          downloadedPhotoCount = _downloadedAssetCount;
        } else {
          if(_downloadedAssetCount % 100 == 0) {
            photoStore.loadMoreAssets(0);
          }
          downloadedVideoCount = _downloadedAssetCount;
        }
    
        
    syncProgressState = tempSyncProgressState;
  }




  _uploadAssetByTypeToServer(DateTime? latestAssetDate, AppAssetType assetType) async {
    try {
      final assets = await _getAssetsSetForAutoBackUp(latestAssetDate , 
          assetType == AppAssetType.PHOTO ? AssetType.image : AssetType.video);

      syncProgressState = assetType == AppAssetType.PHOTO
          ? SyncProgress.UPLOADING_PHOTOS
          : SyncProgress.UPLOADING_VIDEOS;
      
      final tempSyncProgressState = syncProgressState;
      for (final File asset in assets) {
            await AssetService.instance.save(assetType, [asset]);
            
            syncProgressState = SyncProgress.PROCESSING;
            final _totalLocalAssetCount = assets.length;
            if (assetType == AppAssetType.PHOTO) {
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

  _getAssetsSetForAutoBackUp(DateTime? latestAssetDate, AssetType assetType) async {
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

          if(latestAssetDate == null) {
            filteredAssetsByDate.addAll(targetAssets);
          } else{
            filteredAssetsByDate.addAll(targetAssets.where((asset) => (asset.createDateSecond! * 1000) > latestAssetDate.millisecondsSinceEpoch));
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