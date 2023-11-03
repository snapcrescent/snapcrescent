import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/asset/asset_service.dart';
import 'package:snapcrescent_mobile/asset/asset_view_arguments.dart';
import 'package:snapcrescent_mobile/asset/screens/asset_view.dart';
import 'package:snapcrescent_mobile/asset/screens/widgets/asset_thumbnail.dart';
import 'package:snapcrescent_mobile/asset/screens/widgets/asset_year_grid.dart';
import 'package:snapcrescent_mobile/asset/screens/widgets/config_server_prompt.dart';
import 'package:snapcrescent_mobile/asset/screens/widgets/sync_prompt.dart';
import 'package:snapcrescent_mobile/asset/state/asset_state.dart';
import 'package:snapcrescent_mobile/asset/stores/asset_store.dart';
import 'package:snapcrescent_mobile/asset/unified_asset.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/permission_utilities.dart';
import 'package:snapcrescent_mobile/widgets/footer.dart';
import 'package:snapcrescent_mobile/widgets/header.dart';

class AssetListScreen extends StatelessWidget {
  static const routeName = '/assets';
  AssetListScreen();
  @override
  Widget build(BuildContext context) {
    return _AssetListView();
  }
}

class _AssetListView extends StatefulWidget {
  _AssetListView();

  @override
  _AssetListViewState createState() => _AssetListViewState();
}

class _AssetListViewState extends State<_AssetListView> {
  DateTime currentDateTime = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  late AssetStore _assetStore;
  int gridPageNumber = 0;

  _onAssetTap(BuildContext context, int assetIndex) {
    AssetViewArguments arguments = AssetViewArguments(assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      AssetViewScreen.routeName,
      arguments: arguments,
    );
  }

  _shareAssets() async {
    final List<XFile> assetFiles = await AssetService()
        .getAssetFilesForSharing(AssetState().getSelectedIndexes());
    await Share.shareXFiles(assetFiles);
  }

  _downloadAssets() async {
    bool permissionReady =
        await PermissionUtilities().checkAndAskForPhotosPermission();

    if (permissionReady) {
      final bool success = await AssetService()
          .downloadAssetFilesToDevice(AssetState().getSelectedIndexes());
      if (success) {
        ToastService.showSuccess("Successfully downloaded files.");
      }
    }
  }

  _uploadAssets() async {
    bool permissionReady =
        await PermissionUtilities().checkAndAskForPhotosPermission();

    if (permissionReady) {
      final bool success = await AssetService()
          .uploadAssetFilesToServer(AssetState().getSelectedIndexes());
      if (success) {
        ToastService.showSuccess("Successfully uploaded files.");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _listenForNotificationData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _assetStore.loadMoreAssets(++gridPageNumber);

        Timer(Duration(seconds: 2), () => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _listenForNotificationData() {
    final backgroundService = FlutterBackgroundService();
    backgroundService.on('update').listen((Map<String, dynamic>? $event) {
      //SyncState syncMetadata = SyncState.fromJson($event!["syncMetadata"]);
      //if (syncMetadata.downloadedAssetCount % 500 == 0) {
      // _assetStore.refreshStore();
      //}
    }, onError: (e, s) {
      print('error listening for updates: $e, $s');
    }, onDone: () {
      print('background listen closed');
    });
  }

  _getFormattedGroupKey(DateTime groupDateTime) {
    String formattedKey = "";
    if (currentDateTime.year == groupDateTime.year) {
      if (DateUtilities().weekNumber(currentDateTime) ==
          DateUtilities().weekNumber(groupDateTime)) {
        if (currentDateTime.day == groupDateTime.day) {
          formattedKey = 'Today';
        } else {
          formattedKey = DateUtilities()
              .formatDate(groupDateTime, DateUtilities.currentWeekFormat);
        }
      } else {
        formattedKey = DateUtilities()
            .formatDate(groupDateTime, DateUtilities.currentYearFormat);
      }
    } else {
      formattedKey = DateUtilities()
          .formatDate(groupDateTime, DateUtilities.defaultYearFormat);
    }

    return formattedKey;
  }

  int getAssetGroupIndexInScrollView() {
    try {
      final double currentAsset =
          (AssetState().assetYearlyTimeLines.length - 1) *
              _scrollController.offset /
              (_scrollController.position.maxScrollExtent -
                  _scrollController.position.minScrollExtent);
      if (currentAsset.isNaN || currentAsset.isInfinite) {
        return 0;
      }
      return currentAsset.floor();
    } catch (_) {
      return 0;
    }
  }

  Text getScrollLabel() {
    final keys = AssetState().assetYearlyTimeLines;
    final label = keys[getAssetGroupIndexInScrollView()];

    return Text(_getFormattedGroupKey(label.creationDateTime));
  }

  _gridView(Orientation orientation) {
    final assetYearlyTimeLines = AssetState().assetYearlyTimeLines;
    return ListView.builder(
        controller: _scrollController,
        itemCount: assetYearlyTimeLines.length,
        itemBuilder: (BuildContext context, int assetYearlyTimeLineIndex) {
          return AssetYearGrid(assetYearlyTimeLines[assetYearlyTimeLineIndex].assetTimelines);
        });
  }

  _scrollableView(Orientation orientation) {
    return RefreshIndicator(
        onRefresh: () async {
          return Future.delayed(Duration(seconds: 1), () {
            _assetStore.refreshStore();
          });
        },
        child: Container(
            color: Colors.black,
            child: DraggableScrollbar.semicircle(
                labelTextBuilder: (offset) => getScrollLabel(),
                labelConstraints:
                    BoxConstraints.tightFor(width: 150.0, height: 30.0),
                heightScrollThumb: 50.0,
                controller: _scrollController,
                child: _gridView(orientation))));
  }

  _getLeadingIcon() {
    if (AssetState().isAnyItemSelected()) {
      return IconButton(
        onPressed: () {
          for (var asset in AssetState().assetList) {
            asset.selected = false;
          }
          setState(() {});
        },
        icon: Icon(Icons.cancel),
      );
    }
  }

  _body() {
    return Scaffold(
      appBar: AssetState().isAnyItemSelected()
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: _getLeadingIcon(),
              title: Text(!AssetState().isAnyItemSelected()
                  ? ""
                  : ("${AssetState().getSelectedCount()} Selected")),
              backgroundColor: Colors.black,
              actions: [
                if (AssetState().isAnyItemSelected())
                  IconButton(
                      onPressed: () {
                        _uploadAssets();
                      },
                      icon: Icon(Icons.upload, color: Colors.white)),
                IconButton(
                    onPressed: () {
                      _downloadAssets();
                    },
                    icon: Icon(Icons.download, color: Colors.white)),
                IconButton(
                    onPressed: () {
                      _shareAssets();
                    },
                    icon: Icon(Icons.share, color: Colors.white))
              ],
            )
          : Header(),
      bottomNavigationBar: Footer(),
      body: Container(
        color: Colors.black,
        child: Stack(fit: StackFit.expand, children: <Widget>[
          Observer(
              builder: (context) => _assetStore.assetSearchProgress ==
                      AssetSearchProgress.ASSETS_FOUND
                  ? OrientationBuilder(builder: (context, orientation) {
                      return _scrollableView(orientation);
                    })
                  : Container(color: Colors.black)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 0,
                child: SyncPromptWidget(),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ConfigServerPromptWidget(),
            ],
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _assetStore = Provider.of<AssetStore>(context);
    _assetStore.initStore(0);
    return _body();
  }
}
