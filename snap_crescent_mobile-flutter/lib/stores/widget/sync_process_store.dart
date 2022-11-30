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

  cancelSync() {
    executionInProgress = false;
    AssetService.instance.cancelSyncProcess();
  }

  _startSyncProcessForAsset() async {
    try {
      AssetSearchCriteria assetSearchCriteria =
          AssetSearchCriteria.defaultCriteria();
      assetSearchCriteria.resultPerPage = 1;

      final assetCount =
          await AssetService.instance.countOnLocal(assetSearchCriteria);
      final latestAssetsList =
          await AssetService.instance.searchOnLocal(assetSearchCriteria);

      if (assetCount == 0) {
        await _compareLatestLocalAssetDateWithServer(null);
      } else {
        Asset latestAsset = latestAssetsList.first;
        final thumbnail = await ThumbnailService.instance
            .findByIdOnLocal(latestAsset.thumbnailId!);
        latestAsset.thumbnail = thumbnail;

        final metadata = await MetadataService.instance
            .findByIdOnLocal(latestAsset.metadataId!);
        latestAsset.metadata = metadata;

        await _compareLatestLocalAssetDateWithServer(
            latestAsset.metadata!.creationDateTime!);
      }

      syncProgressState = SyncProgress.SYNC_COMPLETED;
    } catch (ex) {
      throw Exception(ex.toString());
    }
  }

  _compareLatestLocalAssetDateWithServer(DateTime? latestAssetDate) async {
    try {
      bool refreshAssetStores = false;
      if (await AssetService.instance.isUserLoggedIn()) {
        AssetSearchCriteria assetSearchCriteria =
            AssetSearchCriteria.defaultCriteria();
        assetSearchCriteria.resultPerPage = 1;
        BaseResponseBean<int, Asset> serverAssetResponse =
            await AssetService.instance.search(assetSearchCriteria);

        if (serverAssetResponse.totalResultsCount! > 0) {
         
          serverAssetResponse = await AssetService.instance.search(assetSearchCriteria);

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

            final newAssetCount =
                await AssetService.instance.countOnLocal(assetSearchCriteria);
            if (serverAssetResponse.totalResultsCount! < newAssetCount) {
              //Server has less records than app, means some server items are deleted
              AssetSearchCriteria assetSearchCriteria =
                  AssetSearchCriteria.defaultCriteria();
              await AssetService.instance
                  .searchAndSyncInactiveRecords(assetSearchCriteria);
            }
          }

           await _uploadAssetsToServer(latestAssetDate, AppAssetType.PHOTO);
          await _uploadAssetsToServer(latestAssetDate, AppAssetType.VIDEO);
        } else {
          // No server sync info is present
          // It is first boot of server or server is reset and it has no data
          // Empty the local sync info
          await AssetService.instance.deleteAllData();
          refreshAssetStores = true;
          await _uploadAssetsToServer(null, AppAssetType.PHOTO);
          await _uploadAssetsToServer(null, AppAssetType.VIDEO); 
        }
      }

      if (refreshAssetStores) {
        assetStore.getAssets(true);
      }
    } catch (e) {
      print("Network error");
    }
  }

  _downloadAssetsFromServer(DateTime? latestAssetDate) async {
    if (!executionInProgress) {
      return;
    }

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

        if (downloadedAssetCount % 1000 == 0) {
          syncProgressState = SyncProgress.PROCESSING;
          assetStore.loadMoreAssets(0);
          syncProgressState = SyncProgress.DOWNLOADING;
        }
      });
    }
  }

  _uploadAssetsToServer(DateTime? latestAssetDate, AppAssetType assetType) async {
    uploadedAssetCount = 0;
    try {
      final assets = await _getAssetsSetForAutoBackUp(latestAssetDate, assetType);

      final filteredAssets = [];
      for (var asset in assets) {
              Metadata metadata = await MetadataRepository.instance.findByNameEndWith(asset.title!);  

              if (metadata.id == null) {
                //The asset is not uploaded to server yet;
                filteredAssets.add(asset);
              }
      }
      

      totalLocalAssetCount = filteredAssets.length;
      syncProgressState = SyncProgress.UPLOADING;

      for (final File asset in filteredAssets) {
        await AssetService.instance.save(assetType, [asset]);
        uploadedAssetCount = uploadedAssetCount + 1;
      }
    } catch (e) {
      print("Network error");
    }
  }

  _getAssetsSetForAutoBackUp(
      DateTime? latestAssetDate,
      AppAssetType assetType) async {
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

          AssetType photoManagerAssetType = assetType == AppAssetType.PHOTO ? AssetType.image : AssetType.video;
          final assetsByAssetType = allAssets.where((asset) => asset.type == photoManagerAssetType);

          final filteredAssetsByDate = [];

          if (latestAssetDate == null) {
            filteredAssetsByDate.addAll(assetsByAssetType);
          } else {
            filteredAssetsByDate.addAll(assetsByAssetType.where((asset) =>
                (asset.createDateSecond! * 1000) >
                latestAssetDate.millisecondsSinceEpoch));
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
