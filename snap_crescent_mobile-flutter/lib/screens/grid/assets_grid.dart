import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/screens/grid/asset_detail.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/date_utilities.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/common_utilities.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:snap_crescent/widgets/asset_thumbnail/asset_thumbnail.dart';

class AssetsGridScreen extends StatelessWidget {
  static const routeName = '/assets';
  AssetsGridScreen();
  @override
  Widget build(BuildContext context) {
    return _AssetGridView();
  }
}

class _AssetGridView extends StatefulWidget {
  _AssetGridView();

  @override
  _AssetGridViewState createState() => _AssetGridViewState();
}

class _AssetGridViewState extends State<_AssetGridView> {
  DateTime currentDateTime = DateTime.now();
  final ScrollController _scrollController = new ScrollController();
  late AssetStore _assetStore;
  bool showProcessing = false;
  int gridPageNumber = 0;

  Timer? timer;
  int periodicInitializerPageNumber = 0;

  _onAssetTap(BuildContext context, int assetIndex) {
    AssetDetailArguments arguments =
        new AssetDetailArguments(assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      AssetDetailScreen.routeName,
      arguments: arguments,
    );
  }

  _shareAssets() async {
    _updateProcessingBarVisibility(true);
    final List<XFile> assetFiles = await _assetStore
        .getAssetFilesForSharing(_assetStore.getSelectedIndexes());
    await Share.shareXFiles(assetFiles);
    _updateProcessingBarVisibility(false);
  }

  _downloadAssets() async {
    bool _permissionReady = await CommonUtilities().checkPermission();

    if (_permissionReady) {
      _updateProcessingBarVisibility(true);
      final bool success = await _assetStore
          .downloadAssetFilesToDevice(_assetStore.getSelectedIndexes());
      if (success) {
        ToastService.showSuccess("Successfully downloaded files.");
      }
      _updateProcessingBarVisibility(false);
    }
  }

  _uploadAssets() async {
    bool _permissionReady = await CommonUtilities().checkPermission();

    if (_permissionReady) {
      _updateProcessingBarVisibility(true);
      final bool success = await _assetStore
          .uploadAssetFilesToServer(_assetStore.getSelectedIndexes());
      if (success) {
        ToastService.showSuccess("Successfully uploaded files.");
      }
      _updateProcessingBarVisibility(false);
    }
  }

  _updateProcessingBarVisibility(bool isVisible) {
    showProcessing = isVisible;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _assetStore.loadMoreAssets(++gridPageNumber);

        Timer(Duration(seconds: 2), () => setState(() {}));
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _periodicallyLoadAssets();
     timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) => 
            _periodicallyLoadAssets()
       );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _periodicallyLoadAssets() {
      if(periodicInitializerPageNumber <= 5) {
      _assetStore.initStore(periodicInitializerPageNumber);
      periodicInitializerPageNumber++;
      } else{
        timer?.cancel();
      }
      
  }

  _getFormattedGroupKey(String key) {
    String formattedKey = "";
    DateTime groupDateTime = DateUtilities().parseDate(key, DateUtilities.defaultYearFormat) ;
    if (currentDateTime.year == groupDateTime.year) {
      if (DateUtilities().weekNumber(currentDateTime) ==
          DateUtilities().weekNumber(groupDateTime)) {
        if (currentDateTime.day == groupDateTime.day) {
          formattedKey = 'Today';
        } else {
          formattedKey = DateUtilities().formatDate(groupDateTime, DateUtilities.currentWeekFormat);
        }
      } else {
        formattedKey = DateUtilities().formatDate(groupDateTime, DateUtilities.currentYearFormat);
      }
    } else {
      formattedKey = DateUtilities().formatDate(groupDateTime, DateUtilities.defaultYearFormat);
    }

    return formattedKey;
  }

  int getAssetGroupIndexInScrollView() {
    try {
      final double currentAsset = (_assetStore.groupedAssets.length - 1) *
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
    final keys = List.from(_assetStore.getGroupedMapKeys());
    final label = keys[getAssetGroupIndexInScrollView()];

    if (label == null) {
      return const Text('');
    }
    return Text(this._getFormattedGroupKey(label));
  }

  _gridView(Orientation orientation, AssetStore assetStore) {
    final keys = assetStore.getGroupedMapKeys();

    return ListView.builder(
        controller: _scrollController,
        itemCount: keys.length + 1,
        itemBuilder: (BuildContext context, int groupIndex) {
          if (groupIndex == keys.length) {
            return Center(
              child: Container(
                width: 60,
                height: 60,
                child: const CircularProgressIndicator(),
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (assetStore.groupedAssets[keys[groupIndex]]!.length > 0)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(5),
                          child:
                              Text(this._getFormattedGroupKey(keys[groupIndex]),
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
                            itemCount: assetStore
                                .groupedAssets[keys[groupIndex]]!.length,
                            itemBuilder: (BuildContext context2, index) {
                              final asset = assetStore
                                  .groupedAssets[keys[groupIndex]]![index];

                              return GestureDetector(
                                onLongPress: () {
                                  asset.selected = !asset.selected;
                                  setState(() {});
                                },
                                onTap: () {
                                  //Grid is in selection mode
                                  if (assetStore.isAnyItemSelected()) {
                                    asset.selected = !asset.selected;
                                    setState(() {});
                                  } //No asset is selected, proceed to asset detail page
                                  else {
                                    _onAssetTap(context,
                                        assetStore.assetList.indexOf(asset));
                                  }
                                },
                                child: AssetThumbnail(
                                    index,
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

  _scrollableView(Orientation orientation, AssetStore assetStore) {
    return RefreshIndicator(
        onRefresh: () {
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
                child: _gridView(orientation, assetStore))));
  }


  _getLeadingIcon() {
    if (_assetStore.isAnyItemSelected()) {
      return IconButton(
        onPressed: () {
          _assetStore.assetList.forEach((asset) {
            asset.selected = false;
          });
          setState(() {});
        },
        icon: Icon(Icons.cancel),
      );
    }
  }

  _body() {
    return Scaffold(
      appBar: _assetStore.isAnyItemSelected()
          ? AppBar(
              leading: _getLeadingIcon(),
              title: Text(!_assetStore.isAnyItemSelected()
                  ? ""
                  : (_assetStore.getSelectedCount().toString() + " Selected")),
              backgroundColor: Colors.black,
              actions: [
                if (_assetStore.isAnyItemSelected())
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
          : AppBar(
              leading: _getLeadingIcon(),
              title: Text(""),
              backgroundColor: Colors.black,
              actions: [
                       PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == "Photos & Videos") {
                                  Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) => AssetsGridScreen(),
                                      ),
                                      (route) => false,//if you want to disable back feature set to false
                                    );
                          } else if (result == "Settings") {
                              Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) => SettingsScreen(),
                                      ),
                                      (route) => true,//if you want to disable back feature set to false
                                    );
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              child: Text("Photos & Videos",),
                              value: "Photos & Videos",
                            ),
                             
                            PopupMenuItem(
                              child: Text("Settings",),
                              value: "Settings",
                            ),
                          ];
                        },
                        ),
              ],
            ),
      body: Column(
        children: <Widget>[
          if (showProcessing)
            Container(
              height: 2,
              child: const LinearProgressIndicator(),
            ),
          Expanded(
              child: Row(
            children: <Widget>[
              Expanded(
                  child: Observer(
                      builder: (context) => _assetStore.assetSearchProgress ==
                              AssetSearchProgress.ASSETS_FOUND
                          ? OrientationBuilder(builder: (context, orientation) {
                              return _scrollableView(orientation, _assetStore);
                            })
                          : _assetStore.assetSearchProgress ==
                                  AssetSearchProgress.PROCESSING
                              ? Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      child: const CircularProgressIndicator(),
                                    ),
                                  ))
                              : Container(color: Colors.black)))
            ],
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _assetStore = Provider.of<AssetStore>(context);

    return _body();
  }
}
