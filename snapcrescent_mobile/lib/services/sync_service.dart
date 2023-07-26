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
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class SyncService extends BaseService {
  static final SyncService _singleton = SyncService._internal();

  factory SyncService() {
    return _singleton;
  }

  SyncService._internal();

  Future<void> syncAssets(Function progressCallBack) async {
    
    SyncState syncMetadata = SyncState(0, 0, 0, 0);

    bool executionInProgress = await AppConfigService().getFlag(Constants.appConfigSyncInProgress);

    bool syncNow = false;

    if (!executionInProgress) {
      syncNow = true;
    } else {
        DateTime? lastSyncActivityTimestamp = await AppConfigService().getDateConfig(Constants.appConfigLastSyncActivityTimestamp, DateUtilities.timeStampFormat);

        if(lastSyncActivityTimestamp != null) {
           int minutesSinceLastBackup =  DateUtilities().calculateMinutesBetween(lastSyncActivityTimestamp, DateTime.now());

            if(minutesSinceLastBackup > 5) {
                syncNow = true;
            }

        } else {
          syncNow = true;
        }
    }

    if (syncNow) {
      bool loggedInToServer = await AppConfigService().getFlag(Constants.appConfigLoggedInFlag);

      if(loggedInToServer) {
        await PhotoManager.setIgnorePermissionCheck(true);
        
        await AppConfigService().updateFlag(Constants.appConfigSyncInProgress, true );

        await _downloadAssetsFromServer(syncMetadata, progressCallBack);

        bool autoBackupEnabled = await AppConfigService().getFlag(Constants.appConfigAutoBackupFlag);
        
        if(autoBackupEnabled) {
          await _uploadAssetsToServer(syncMetadata, progressCallBack);
        }
        
        await NotificationService().clearNotifications();
        await AppConfigService().updateFlag(Constants.appConfigSyncInProgress, false );
      }
    }
  }

  Future<bool> _downloadAssetsFromServer(
      SyncState syncMetadata, Function progressCallBack) async {
    
    bool refreshAssetStores = false;

    DateTime? latestAssetDate =
        await AssetService().getLatestAssetDate();

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
              await _downloadAssets(null, syncMetadata, progressCallBack);
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

  _downloadAssets(DateTime? latestAssetDate, SyncState syncMetadata,
      Function progressCallBack) async {
    
    syncMetadata.downloadedAssetCount = 0;

    AssetSearchCriteria searchCriteria = AssetSearchCriteria.defaultCriteria();
    searchCriteria.resultPerPage = 1;
    searchCriteria.sortOrder = Direction.DESC;

    if (latestAssetDate != null) {
      searchCriteria.fromDate = latestAssetDate;
    }

    final assetCountResponse =
        await AssetService().search(searchCriteria);
    syncMetadata.totalServerAssetCount = assetCountResponse.totalResultsCount!;

    if (syncMetadata.totalServerAssetCount > 0) {
      postDownloadUpdates(syncMetadata, progressCallBack);

      searchCriteria.pageNumber = 0;
      searchCriteria.resultPerPage = syncMetadata.totalServerAssetCount;
      searchCriteria.resultType = ResultType.SEARCH;

      await AssetService().searchAndSync(searchCriteria,
          (downloadedAssetCount) {
        syncMetadata.downloadedAssetCount = downloadedAssetCount;

        if (
          syncMetadata.downloadedAssetCount % 10 == 0
          || syncMetadata.downloadedAssetCount == syncMetadata.totalServerAssetCount
          ) {
          postDownloadUpdates(syncMetadata, progressCallBack);
        } else if(syncMetadata.downloadedAssetCount < 10) {
          postDownloadUpdates(syncMetadata, progressCallBack);
        }
      });
    }
  }

  Future<bool> _uploadAssetsToServer(
      SyncState syncMetadata, Function progressCallBack) async {
    bool refreshAssetStores = false;
    syncMetadata.uploadedAssetCount = 0;
    try {
        List<AssetEntity> assets = await _getAssetsSetForAutoBackUp();

        List<File> filteredAssets = [];
        for (var asset in assets) {
          
          Metadata? metadata = await MetadataService().findByLocalAssetId(asset.id);
          
          if (metadata == null) {
            //The asset is not uploaded to server yet;
            File? assetFile = await asset.file;

            if(assetFile != null) {
              filteredAssets.add(assetFile);
            }
          }
        }

        filteredAssets.sort((File a, File b) =>
            a.lastModifiedSync().compareTo(b.lastModifiedSync()));

        syncMetadata.totalLocalAssetCount = filteredAssets.length;

        if (syncMetadata.totalLocalAssetCount > 0) {
          postUploadUpdates(syncMetadata, progressCallBack);
          refreshAssetStores = true;
        }

        for (final File asset in filteredAssets) {
          postUploadUpdates(syncMetadata, progressCallBack);
          await AssetService().save([asset]);
          syncMetadata.uploadedAssetCount = syncMetadata.uploadedAssetCount + 1;
          postUploadUpdates(syncMetadata, progressCallBack);
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

        List<String> autoBackupFolderNameList = await AppConfigService().getStringListConfig(Constants.appConfigAutoBackupFolders, ",");
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

  postDownloadUpdates(SyncState syncMetadata, Function progressCallBack) {
    NotificationService().showNotification(
        "Downloading photos and videos",
        '''Downloaded : ${syncMetadata.downloadedPercentageString()}''',
        Constants.downloadProgressNotificationChannel);
    updateLastSyncActivityTimestamp();
    progressCallBack(syncMetadata);
  }

  postUploadUpdates(SyncState syncMetadata, Function progressCallBack) {
    NotificationService().showNotification(
        "Uploading photos and videos",
        '''Uploaded : ${syncMetadata.uploadPercentageString()}''',
        Constants.uploadProgressNotificationChannel);
    updateLastSyncActivityTimestamp();
    progressCallBack(syncMetadata);
  }

  updateLastSyncActivityTimestamp() async{
    await AppConfigService().updateDateConfig(Constants.appConfigLastSyncActivityTimestamp, DateTime.now(), DateUtilities.timeStampFormat);
  }
}
