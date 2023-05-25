import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/metadata.dart';
import 'package:snap_crescent/models/sync_state.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/base_service.dart';
import 'package:snap_crescent/services/notification_service.dart';
import 'package:snap_crescent/services/settings_service.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:snap_crescent/utils/date_utilities.dart';

class SyncService extends BaseService {
  SyncService._privateConstructor() : super();

  factory SyncService() {
    return _instance;
  }

  static final SyncService _instance = SyncService._privateConstructor();

  static bool executionInProgress = false;

  Future<void> syncAssets(Function progressCallBack) async {
    
    SyncState syncMetadata = new SyncState(0, 0, 0, 0);

    if (!executionInProgress) {
      bool _loggedInToServer = await SettingsService.instance.getFlag(Constants.appConfigLoggedInFlag);

      if(_loggedInToServer) {
        executionInProgress = true;

        AppConfig appConfigLastSyncTimestampConfig = new AppConfig(
            configKey: Constants.appConfigLastSyncTimestamp,
            configValue: DateUtilities().formatDate(DateTime.now(), DateUtilities.timeStampFormat));
          await AppConfigRepository.instance.saveOrUpdateConfig(appConfigLastSyncTimestampConfig);

        await _downloadAssetsFromServer(syncMetadata, progressCallBack);

        bool _autoBackupEnabled = await SettingsService.instance.getFlag(Constants.appConfigAutoBackupFlag);
        
        if(_autoBackupEnabled) {
          await _uploadAssetsToServer(syncMetadata, progressCallBack);
        }
        
        executionInProgress = false;
      }
    }
  }

  Future<bool> _downloadAssetsFromServer(
      SyncState syncMetadata, Function progressCallBack) async {
    
    bool refreshAssetStores = false;

    DateTime? latestAssetDate =
        await AssetService.instance.getLatestAssetDate();

    try {
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
            await _downloadAssets(
                null, syncMetadata, progressCallBack);
            refreshAssetStores = true;
          } else {
            if (latestServerAssetDate != latestAssetDate) {
              //Local latest asset date is not matching with server's latest asset
              await _downloadAssets(
                  latestAssetDate, syncMetadata, progressCallBack);
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
              //Server has more records than app, means some server items were not synced due to error and coming up in latest sync call
              // Need to sync everything
              await _downloadAssets(null, syncMetadata, progressCallBack);
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
    } catch (e) {
      print("Network error");
    }

    return refreshAssetStores;
  }

  _downloadAssets(DateTime? latestAssetDate, SyncState syncMetadata,
      Function progressCallBack) async {
    if (!executionInProgress) {
      return;
    }

    syncMetadata.downloadedAssetCount = 0;

    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.resultPerPage = 1;
    searchCriteria.sortOrder = Direction.DESC;

    if (latestAssetDate != null) {
      searchCriteria.fromDate = latestAssetDate;
    }

    final assetCountResponse =
        await AssetService.instance.search(searchCriteria);
    syncMetadata.totalServerAssetCount = assetCountResponse.totalResultsCount!;

    if (syncMetadata.totalServerAssetCount > 0) {
      postDownloadNotification(syncMetadata, progressCallBack);

      searchCriteria.pageNumber = 0;
      searchCriteria.resultPerPage = syncMetadata.totalServerAssetCount;
      searchCriteria.resultType = ResultType.SEARCH;

      await AssetService.instance.searchAndSync(searchCriteria,
          (_downloadedAssetCount) {
        syncMetadata.downloadedAssetCount = _downloadedAssetCount;

        if (syncMetadata.downloadedAssetCount % 10 == 0) {
          postDownloadNotification(syncMetadata, progressCallBack);
          postDownloadNotification(syncMetadata, progressCallBack);
        }
      });
    }
  }

  Future<bool> _uploadAssetsToServer(
      SyncState syncMetadata, Function progressCallBack) async {
    bool refreshAssetStores = false;
    syncMetadata.uploadedAssetCount = 0;
    try {
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

        filteredAssets.sort((File a, File b) =>
            a.lastModifiedSync().compareTo(b.lastModifiedSync()));

        syncMetadata.totalLocalAssetCount = filteredAssets.length;

        if (syncMetadata.totalLocalAssetCount > 0) {
          postUploadNotification(syncMetadata, progressCallBack);
          refreshAssetStores = true;
        }

        for (final File asset in filteredAssets) {
          postUploadNotification(syncMetadata, progressCallBack);
          await AssetService.instance.save([asset]);
          syncMetadata.uploadedAssetCount = syncMetadata.uploadedAssetCount + 1;
          postUploadNotification(syncMetadata, progressCallBack);
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

  postDownloadNotification(SyncState syncMetadata, Function progressCallBack) {
    NotificationService.instance.showNotification(
        "Downloading photos and videos",
        "Downloaded : " + syncMetadata.downloadedPercentage(),
        Constants.downloadProgressNotificationChannel);
    progressCallBack(syncMetadata);
  }

  postUploadNotification(SyncState syncMetadata, Function progressCallBack) {
    NotificationService.instance.showNotification(
        "Uploading photos and videos",
        "Uploaded : " + syncMetadata.uploadPercentage(),
        Constants.uploadProgressNotificationChannel);
    progressCallBack(syncMetadata);
  }
}
