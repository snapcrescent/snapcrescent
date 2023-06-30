import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
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
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer = Timer.periodic(Duration(seconds: 60),
          (Timer t) => _runSync());
    });
  }

  void _runSync() async{
    await SyncService().syncAssets((SyncState syncMetadata) => {
      _assetStore.refreshStore()
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _assetStore = Provider.of<AssetStore>(context);
    return Container();
  }
}