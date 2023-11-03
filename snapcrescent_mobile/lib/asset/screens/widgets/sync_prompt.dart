import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapcrescent_mobile/asset/stores/asset_store.dart';

import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/sync/sync_service.dart';
import 'package:snapcrescent_mobile/sync/state/sync_state.dart';

class SyncPromptWidget extends StatelessWidget  {
  
  
  void _runSync(SyncState syncState ) async {
    SyncService().setSyncState(syncState);
    await SyncService().syncFromServer();
    //await NotificationService().clearNotifications();
    await SyncService().syncToServer();
    //await NotificationService().clearNotifications();
  }

  postDownloadUpdates(SyncState syncMetadata, AssetStore assetStore) {
    if (syncMetadata.getDownloadedAssetCount() > 0) {
      refreshAssetStoreIfNeeded(syncMetadata, assetStore);
      NotificationService().showProgressNotification(
          "Syncing",
          '''Syncing from Server : ${syncMetadata.downloadPercentageString()}''',
          syncMetadata.getTotalServerAssetCount(),
          syncMetadata.getDownloadedAssetCount(),
          "Sync Progress");
    }
  }

  postUploadUpdates(SyncState syncMetadata, AssetStore assetStore) {
    if (syncMetadata.getUploadedAssetCount() > 0) {
      refreshAssetStoreIfNeeded(syncMetadata, assetStore);
      NotificationService().showProgressNotification(
          "Syncing",
          '''Syncing to Server : ${syncMetadata.uploadPercentageString()}''',
          syncMetadata.getTotalLocalAssetCount(),
          syncMetadata.getUploadedAssetCount(),
          "Sync Progress");
    }
  }

  refreshAssetStoreIfNeeded(SyncState syncMetadata, AssetStore assetStore) {
    if ((syncMetadata.downloadPercentage() > 0 &&
            syncMetadata.downloadPercentage() % 25 == 0) ||
        (syncMetadata.getUploadedAssetCount() > 0 &&
            syncMetadata.uploadPercentage() % 25 == 0)) {
      assetStore.refreshStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    AssetStore assetStore = Provider.of<AssetStore>(context);
    SyncState syncState = Provider.of<SyncState>(context);

    syncState.addListener(() {
      postDownloadUpdates(syncState, assetStore);
      postUploadUpdates(syncState, assetStore);
    });

    Future.delayed(Duration(seconds: 5), () => _runSync(syncState));
    
    return Container();
  }
}
