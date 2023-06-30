import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:snapcrescent_mobile/models/sync_state.dart';
import 'package:snapcrescent_mobile/services/sync_service.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';

class SyncProcessWidget extends StatefulWidget {
  @override
  SyncProcessWidgetState createState() => SyncProcessWidgetState();
}

class SyncProcessWidgetState extends State<SyncProcessWidget> {
  
  late AssetStore _assetStore;
  

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSync();
    });
  }

  void _runSync() async{
    await SyncService().syncAssets((SyncState syncMetadata) => {
      if(
        (syncMetadata.downloadedPercentage() > 0 && syncMetadata.downloadedPercentage() % 25 == 0)
        ||
        (syncMetadata.uploadPercentage() > 0 && syncMetadata.uploadPercentage() % 25 == 0)
      )
      _assetStore.refreshStore()
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _assetStore = Provider.of<AssetStore>(context);
    return Container();
  }
}