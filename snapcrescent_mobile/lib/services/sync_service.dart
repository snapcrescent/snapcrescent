import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/asset/asset.dart';
import 'package:snapcrescent_mobile/models/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/models/common/base_response_bean.dart';
import 'package:snapcrescent_mobile/models/metadata/metadata.dart';
import 'package:snapcrescent_mobile/models/sync_state.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/services/metadata_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:quiver/iterables.dart';

class SyncService extends BaseService {
  static final SyncService _singleton = SyncService._internal();

  factory SyncService() {
    return _singleton;
  }

  SyncService._internal();

  SyncState? _syncState;

  bool _cancelletionFlag = false;

  setSyncState(SyncState syncState) {
    _syncState = syncState;
  }

  Future<void> syncFromServer() async {
    bool syncNow = await _canSyncExecute();

    if (syncNow) {
      await _startExecution();
      await _downloadAssetsFromServer();
      await _stopExecution();
    }
  }

  Future<void> syncToServer() async {
    bool syncNow = await _canSyncExecute();

    if (syncNow) {
      await _startExecution();
      bool autoBackupEnabled =
          await AppConfigService().getFlag(Constants.appConfigAutoBackupFlag);
      if (autoBackupEnabled) {
        await PhotoManager.setIgnorePermissionCheck(true);
        await _uploadAssetsToServer();
      }
      await _stopExecution();
    }
  }

  Future<bool> _canSyncExecute() async {
    bool canSync = false;

    bool loggedInToServer =
        await AppConfigService().getFlag(Constants.appConfigLoggedInFlag);

    if (loggedInToServer) {
      bool executionInProgress =
          await AppConfigService().getFlag(Constants.appConfigSyncInProgress);

      if (!executionInProgress) {
        canSync = true;
      } else {
        DateTime? lastSyncActivityTimestamp = await AppConfigService()
            .getDateConfig(Constants.appConfigLastSyncActivityTimestamp,
                DateUtilities.timeStampFormat);

        if (lastSyncActivityTimestamp != null) {
          int minutesSinceLastBackup = DateUtilities().calculateMinutesBetween(
              lastSyncActivityTimestamp, DateTime.now());

          if (minutesSinceLastBackup > 5) {
            canSync = true;
          }
        } else {
          canSync = true;
        }
      }
    }

    return canSync;
  }

  cancelSyncProcess() {
    _cancelletionFlag = true;
  }

  Future<void> _startExecution() async {
    await AppConfigService()
        .updateFlag(Constants.appConfigSyncInProgress, true);
  }

  Future<void> _stopExecution() async {
    await AppConfigService()
        .updateFlag(Constants.appConfigSyncInProgress, false);
  }

  Future<bool> _downloadAssetsFromServer() async {
    bool refreshAssetStores = false;

    DateTime? latestAssetDate = await AssetService().getLatestAssetDate();

    try {
      AssetSearchCriteria assetSearchCriteria =
          AssetSearchCriteria.defaultCriteria();
      assetSearchCriteria.resultPerPage = 1;

      BaseResponseBean<int, Asset> serverAssetResponse =
          await AssetService().search(assetSearchCriteria);

      if (serverAssetResponse.totalResultsCount! > 0) {
        DateTime latestServerAssetDate =
            serverAssetResponse.objects!.last.metadata!.creationDateTime!;

        if (latestAssetDate == null) {
          // No local sync info is present
          // It is a first boot or app is reset
          // Need to sync everything
          await _downloadAssets(null);
          refreshAssetStores = true;
        } else {
          if (latestServerAssetDate != latestAssetDate) {
            //Local latest asset date is not matching with server's latest asset
            await _downloadAssets(latestAssetDate);
            refreshAssetStores = true;
          }

          final newAssetCount = await AssetService().countOnLocal();
          if (serverAssetResponse.totalResultsCount! < newAssetCount) {
            //Server has less records than app, means some server items are deleted
            AssetSearchCriteria assetSearchCriteria =
                AssetSearchCriteria.defaultCriteria();
            await AssetService()
                .searchAndSyncInactiveRecords(assetSearchCriteria);
            refreshAssetStores = true;
          } else if (serverAssetResponse.totalResultsCount! > newAssetCount) {
            //Server has more records than app, means some server items were not synced due to error and coming up in latest sync call
            // Need to sync everything
            await _downloadAssets(null);
            refreshAssetStores = true;
          }
        }
      } else {
        // No records present on server
        // It is first boot of server or server is reset and it has no data
        // Empty the local sync info
        await AssetService().deleteAllData();

        refreshAssetStores = true;
      }
    } catch (e) {
      print("Network error");
    }

    return refreshAssetStores;
  }

  _downloadAssets(DateTime? latestAssetDate) async {
    _cancelletionFlag = false;
    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.resultPerPage = 1;
    searchCriteria.sortOrder = Direction.DESC;

    if (latestAssetDate != null) {
      searchCriteria.fromDate = latestAssetDate;
    }

    final assetCountResponse = await AssetService().search(searchCriteria);

    if (assetCountResponse.totalResultsCount! > 0) {
      if (_syncState != null) {
        _syncState!
            .setTotalServerAssetCount(assetCountResponse.totalResultsCount!);
        _syncState!.setDownloadedAssetCount(0);
      }

      searchCriteria.resultPerPage = 100;
      searchCriteria.resultType = ResultType.SEARCH;
      int numberOfPages = (assetCountResponse.totalResultsCount! /
              searchCriteria.resultPerPage!)
          .ceil();

      for (var pageNumber = 0; pageNumber <= numberOfPages; pageNumber++) {
        searchCriteria.pageNumber = pageNumber;

        if (_cancelletionFlag == false) {
          await AssetService().searchAndSync(searchCriteria);

          if (_syncState != null) {
            if (pageNumber == numberOfPages) {
              _syncState!.setDownloadedAssetCount(
                  assetCountResponse.totalResultsCount!);
            } else {
              _syncState!.setDownloadedAssetCount(
                  pageNumber * searchCriteria.resultPerPage!);
            }

            await _updateLastSyncActivityTimestamp();
          }
        }
      }
    }
  }

  Future<bool> _uploadAssetsToServer() async {
    _cancelletionFlag = false;
    bool refreshAssetStores = false;
    try {
      List<AssetEntity> assets = await _getAssetsSetForAutoBackUp();

      List<File> filteredAssets = [];
      for (var asset in assets) {
        Metadata? metadata =
            await MetadataService().findByLocalAssetId(asset.id);

        if (metadata == null) {
          //The asset is not uploaded to server yet;
          File? assetFile = await asset.file;

          if (assetFile != null) {
            filteredAssets.add(assetFile);
          }
        }
      }

      filteredAssets.sort((File a, File b) =>
          a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      if (filteredAssets.isNotEmpty) {
        refreshAssetStores = true;

        if (_syncState != null) {
          _syncState!.setTotalLocalAssetCount(filteredAssets.length);
          _syncState!.setUploadedAssetCount(0);
        }

        final Iterable<List<File>> partitionedFiles =
            partition(filteredAssets, 5);

        int index = 0;
        for (final List<File> assets in partitionedFiles) {
          if (_cancelletionFlag == false) {
            await AssetService().save(assets);
            if (_syncState != null) {
              _syncState!.setUploadedAssetCount(index);
              index++;
            }
            await _updateLastSyncActivityTimestamp();
          }
        }
      }
    } catch (e) {
      print("Network error");
    }

    return refreshAssetStores;
  }

  Future<List<AssetEntity>> _getAssetsSetForAutoBackUp() async {
    List<AssetEntity> assets = [];

    try {
      final List<AssetPathEntity> folders =
          await PhotoManager.getAssetPathList();
      folders.sort(
          (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

      List<String> autoBackupFolderNameList = await AppConfigService()
          .getStringListConfig(Constants.appConfigAutoBackupFolders, ",");
      List<AssetPathEntity> autoBackupFolders = [];

      for (int i = 0; i < folders.length; i++) {
        if (autoBackupFolderNameList.contains(folders[i].id)) {
          autoBackupFolders.add(folders[i]);
        }
      }

      for (int i = 0; i < autoBackupFolders.length; i++) {
        AssetPathEntity folder = autoBackupFolders[i];

        final allAssets = await folder.getAssetListRange(
          start: 0, // start at index 0
          end: 100000, // end at a very big index (to get all the assets)
        );

        assets = allAssets;
      }
    } catch (e) {
      print("Network error");
    }

    return assets;
  }

  _updateLastSyncActivityTimestamp() async {
    await AppConfigService().updateDateConfig(
        Constants.appConfigLastSyncActivityTimestamp,
        DateTime.now(),
        DateUtilities.timeStampFormat);
  }
}
