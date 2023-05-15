import 'dart:async';

import 'package:mobx/mobx.dart';

import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/metadata.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart';

part 'sync_process_store.g.dart';

class SyncProcessStore = _SyncProcessStore with _$SyncProcessStore;

abstract class _SyncProcessStore with Store {
  @observable
  SyncProgress syncProgressState = SyncProgress.CONTACTING_SERVER;

  int downloadedAssetCount = 0;
  int totalServerAssetCount = 0;

  int uploadedAssetCount = 0;
  int totalLocalAssetCount = 0;

  bool executionInProgress = false;

  late AssetStore assetStore;

  @action
  Future<void> startSyncProcess() async {
    if (executionInProgress) {
      return;
    }

    executionInProgress = true;

    await _startSyncProcessForAsset();

    executionInProgress = false;
  }

  _startSyncProcessForAsset() async {
    syncProgressState = SyncProgress.PROCESSING;

    try {
      final latestAssetDate = await AssetService.instance.getLatestAssetDate();

      bool refreshAssetStoresPostDownload = await _compareLatestLocalAssetDateWithServer(latestAssetDate);

      bool refreshAssetStoresPostUpload = await _uploadAssetsToServer();
      
      if (refreshAssetStoresPostDownload || refreshAssetStoresPostUpload) {
        assetStore.refreshStore();
      }
    } catch (ex) {
      throw Exception(ex.toString());
    }

    syncProgressState = SyncProgress.SYNC_COMPLETED;
  }

  Future<bool> _compareLatestLocalAssetDateWithServer(
      DateTime? latestAssetDate) async {
    bool refreshAssetStores = false;

    try {
      if (await AssetService.instance.isUserLoggedIn()) {
        AssetSearchCriteria assetSearchCriteria =
            AssetSearchCriteria.defaultCriteria();
        assetSearchCriteria.resultPerPage = 1;

        BaseResponseBean<int, Asset> serverAssetResponse =
            await AssetService.instance.search(assetSearchCriteria);

        if (serverAssetResponse.totalResultsCount! > 0) {
          DateTime latestServerAssetDate =
              serverAssetResponse.objects!.last.metadata!.creationDateTime!;

          if (latestAssetDate == null) {
            // No local sync info is present
            // It is a first boot or app is reset
            // Need to sync everything
            await _downloadAssetsFromServer(null);
            refreshAssetStores = true;
          } else {
            if (latestServerAssetDate != latestAssetDate) {
              //Local latest asset date is not matching with server's latest asset
              await _downloadAssetsFromServer(latestAssetDate);
              refreshAssetStores = true;
            }

            final newAssetCount = await AssetService.instance.countOnLocal();
            if (serverAssetResponse.totalResultsCount! < newAssetCount) {
              //Server has less records than app, means some server items are deleted
              AssetSearchCriteria assetSearchCriteria =
                  AssetSearchCriteria.defaultCriteria();
              await AssetService.instance
                  .searchAndSyncInactiveRecords(assetSearchCriteria);
              refreshAssetStores = true;
            } else if (serverAssetResponse.totalResultsCount! > newAssetCount) {
              //Server has more records than app, means some server items are were not synced due to some error and now not coming up in latest sync call
              // Need to sync everything
              await _downloadAssetsFromServer(null);
              refreshAssetStores = true;
            }
          }
        } else {
          // No records present on server
          // It is first boot of server or server is reset and it has no data
          // Empty the local sync info
          await AssetService.instance.deleteAllData();

          refreshAssetStores = true;
        }
      }
    } catch (e) {
      print("Network error");
    }

    return refreshAssetStores;
  }

  _downloadAssetsFromServer(DateTime? latestAssetDate) async {
    if (!executionInProgress) {
      return;
    }

    downloadedAssetCount = 0;

    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.resultPerPage = 1;
    searchCriteria.sortOrder = Direction.DESC;

    if (latestAssetDate != null) {
      searchCriteria.fromDate = latestAssetDate;
    }

    final assetCountResponse =
        await AssetService.instance.search(searchCriteria);
    totalServerAssetCount = assetCountResponse.totalResultsCount!;

    if (totalServerAssetCount > 0) {
      syncProgressState = SyncProgress.DOWNLOADING;

      searchCriteria.pageNumber = 0;
      searchCriteria.resultPerPage = totalServerAssetCount;
      searchCriteria.resultType = ResultType.SEARCH;

      await AssetService.instance.searchAndSync(searchCriteria,
          (_downloadedAssetCount) {
        downloadedAssetCount = _downloadedAssetCount;

        if (downloadedAssetCount % 10 == 0) {
          syncProgressState = SyncProgress.PROCESSING;

          syncProgressState = SyncProgress.DOWNLOADING;
        }

        if (downloadedAssetCount % 500 == 0) {
          assetStore.loadMoreAssets(0);
        }
      });
    }
  }

  Future<bool> _uploadAssetsToServer() async {
    bool refreshAssetStores = false;
    uploadedAssetCount = 0;
    try {
      if (await AssetService.instance.isUserLoggedIn()) {
        List<File> assets = await _getAssetsSetForAutoBackUp();

        List<File> filteredAssets = [];
        for (var asset in assets) {
          String filePath = asset.path;
          String fileName = filePath.substring(
              filePath.lastIndexOf("/") + 1, filePath.length);
          Metadata metadata =
              await MetadataRepository.instance.findByNameEndWith(fileName);

          if (metadata.id == null) {
            //The asset is not uploaded to server yet;
            filteredAssets.add(asset);
          }
        }

        filteredAssets.sort((File a,File b)  => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

        totalLocalAssetCount = filteredAssets.length;
        
        if(totalLocalAssetCount > 0) {
          syncProgressState = SyncProgress.UPLOADING;
          refreshAssetStores = true;
        }

        for (final File asset in filteredAssets) {
          syncProgressState = SyncProgress.PROCESSING;
          await AssetService.instance.save([asset]);
          uploadedAssetCount = uploadedAssetCount + 1;
          syncProgressState = SyncProgress.UPLOADING;
        }
      }
    } catch (e) {
      print("Network error");
    }

    return refreshAssetStores;
  }

  _getAssetsSetForAutoBackUp() async {
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

          for (final AssetEntity asset in allAssets) {
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
