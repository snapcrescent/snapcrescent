import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:snapcrescent_mobile/models/sync_state.dart';
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/services/sync_service.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';

class SyncProcessWidget extends StatefulWidget {
  @override
  SyncProcessWidgetState createState() => SyncProcessWidgetState();
}

class SyncProcessWidgetState extends State<SyncProcessWidget> {
  late AssetStore _assetStore;
  late SyncState _syncState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSync();
    });
  }

  void _runSync() async {
    SyncService().setSyncState(_syncState);
    await SyncService().syncFromServer();
    await NotificationService().clearNotifications();
    await SyncService().syncToServer();
    await NotificationService().clearNotifications();
  }

  postDownloadUpdates(SyncState syncMetadata) {
    if (syncMetadata.getDownloadedAssetCount() > 0) {
      refreshAssetStoreIfNeeded(syncMetadata);
      NotificationService().showProgressNotification(
          "Syncing",
          '''Syncing from Server : ${syncMetadata.downloadPercentageString()}''',
          syncMetadata.getTotalServerAssetCount(),
          syncMetadata.getDownloadedAssetCount());

      /*
      NotificationService().showNotification(
          "Syncing from Server",
          '''Progress : ${syncMetadata.downloadedPercentageString()}''',
          Constants.downloadProgressNotificationChannel);
      */
    }
  }

  postUploadUpdates(SyncState syncMetadata) {
    if (syncMetadata.getUploadedAssetCount() > 0) {
      refreshAssetStoreIfNeeded(syncMetadata);
      NotificationService().showProgressNotification(
          "Syncing",
          '''Syncing to Server : ${syncMetadata.uploadPercentageString()}''',
          syncMetadata.getTotalLocalAssetCount(),
          syncMetadata.getUploadedAssetCount());

      /*
      NotificationService().showNotification(
          "Syncing to Server",
          '''Progress : ${syncMetadata.uploadPercentageString()}''',
          Constants.uploadProgressNotificationChannel);
      */
    }
  }

  refreshAssetStoreIfNeeded(SyncState syncMetadata) {
    if ((syncMetadata.downloadPercentage() > 0 &&
            syncMetadata.downloadPercentage() % 25 == 0) ||
        (syncMetadata.getUploadedAssetCount() > 0 &&
            syncMetadata.uploadPercentage() % 25 == 0)) {
      _assetStore.refreshStore();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _assetStore = Provider.of<AssetStore>(context);
    _syncState = Provider.of<SyncState>(context);

    _syncState.addListener(() {
      postDownloadUpdates(_syncState);
      postUploadUpdates(_syncState);
    });

    return Container();
  }
}
