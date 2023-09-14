import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/models/asset/asset_view_arguments.dart';
import 'package:snapcrescent_mobile/screens/asset/asset_view.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/state/asset_state.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:snapcrescent_mobile/stores/asset/asset_store.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/screens/asset/widgets/asset_thumbnail.dart';
import 'package:snapcrescent_mobile/screens/asset/widgets/config_server_prompt.dart';
import 'package:snapcrescent_mobile/screens/asset/widgets/sync_process.dart';
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

  _getFormattedGroupKey(String key) {
    String formattedKey = "";
    DateTime groupDateTime =
        DateUtilities().parseDate(key, DateUtilities.defaultYearFormat);
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
      final double currentAsset = (AssetState().groupedAssets.length - 1) *
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
    final keys = AssetState().groupedMapKeys;
    final label = keys[getAssetGroupIndexInScrollView()];

    return Text(_getFormattedGroupKey(label));
  }

  _gridView(Orientation orientation) {
    final keys = AssetState().groupedMapKeys;

    return ListView.builder(
        controller: _scrollController,
        itemCount: keys.length + 1,
        itemBuilder: (BuildContext context, int groupIndex) {
          if (groupIndex == keys.length) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                )
              ],
            ));
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (AssetState().groupedAssets[keys[groupIndex]]!.isNotEmpty)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(_getFormattedGroupKey(keys[groupIndex]),
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                        GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            physics:
                                NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                            shrinkWrap: true,
                            itemCount: AssetState()
                                .groupedAssets[keys[groupIndex]]!
                                .length,
                            itemBuilder: (BuildContext context2, index) {
                              final asset = AssetState()
                                  .groupedAssets[keys[groupIndex]]![index];

                              return GestureDetector(
                                onLongPress: () {
                                  asset.selected = !asset.selected;
                                  setState(() {});
                                },
                                onTap: () {
                                  //Grid is in selection mode
                                  if (AssetState().isAnyItemSelected()) {
                                    asset.selected = !asset.selected;
                                    setState(() {});
                                  } //No asset is selected, proceed to asset detail page
                                  else {
                                    _onAssetTap(context,
                                        AssetState().assetList.indexOf(asset));
                                  }
                                },
                                child: AssetThumbnail(
                                    asset,
                                    asset.assetSource == AssetSource.CLOUD
                                        ? Future.value(asset.asset)
                                        : asset.assetEntity!.thumbnailData,
                                    asset.selected),
                              );
                            })
                      ])
              ],
            );
          }
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
                child: SyncProcessWidget(),
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
