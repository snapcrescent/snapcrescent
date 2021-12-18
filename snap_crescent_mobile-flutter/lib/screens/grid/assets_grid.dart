import 'dart:async';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/screens/grid/asset_detail.dart';
import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/stores/asset/video_store.dart';
import 'package:snap_crescent/widgets/sync_process/sync_process.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/common_utils.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:snap_crescent/widgets/asset_thumbnail/asset_thumbnail.dart';
import 'package:snap_crescent/widgets/bottom-navigation_bar/bottom-navigation_bar.dart';

class AssetsGridScreen extends StatelessWidget {
  static const routeName = '/assets';

  final ASSET_TYPE type;

  AssetsGridScreen(this.type);

  @override
  Widget build(BuildContext context) {
    return _AssetGridView(type);
  }
}

class _AssetGridView extends StatefulWidget {
  final ASSET_TYPE type;

  _AssetGridView(this.type);

  @override
  _AssetGridViewState createState() => _AssetGridViewState();
}

class _AssetGridViewState extends State<_AssetGridView> {
  DateTime currentDateTime = DateTime.now();
  final DateFormat currentWeekFormatter = DateFormat('EEEE');
  final DateFormat currentYearFormatter = DateFormat('E, MMM dd');
  final DateFormat defaultYearFormatter = DateFormat('E, MMM dd, yyyy');

  final ScrollController _scrollController = new ScrollController();
  late AssetStore _assetStore;

  int pageNumber = 0;

  _onAssetTap(BuildContext context, int assetIndex) {
    AssetDetailArguments arguments =
        new AssetDetailArguments(type: widget.type, assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      AssetDetailScreen.routeName,
      arguments: arguments,
    );
  }

  _shareAsset() async {
    //await _shareFile();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _assetStore.loadMoreAssets(++pageNumber);

        Timer(Duration(seconds: 2), () => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getFormattedGroupKey(String key) {
    String formattedKey = "";
    DateTime groupDateTime = defaultYearFormatter.parse(key);
    if (currentDateTime.year == groupDateTime.year) {
      if (CommonUtils().weekNumber(currentDateTime) ==
          CommonUtils().weekNumber(groupDateTime)) {
        if (currentDateTime.day == groupDateTime.day) {
          formattedKey = 'Today';
        } else {
          formattedKey = currentWeekFormatter.format(groupDateTime);
        }
      } else {
        formattedKey = currentYearFormatter.format(groupDateTime);
      }
    } else {
      formattedKey = defaultYearFormatter.format(groupDateTime);
    }

    return formattedKey;
  }

  int getPhotoGroupIndexInScrollView() {
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
    final label = keys[getPhotoGroupIndexInScrollView()];

    if (label == null) {
      return const Text('');
    }
    return Text(this._getFormattedGroupKey(label));
  }

  _gridView(Orientation orientation, AssetStore assetStore) {
    final keys = assetStore.getGroupedMapKeys();
    return new ListView.builder(
        controller: _scrollController,
        itemCount: keys.length + 1,
        itemBuilder: (BuildContext ctxt, int groupIndex) {
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
                            itemBuilder: (BuildContext ctx, index) {
                              final asset = assetStore
                                  .groupedAssets[keys[groupIndex]]![index];

                              return GestureDetector(
                                onLongPress: () {
                                  asset.selected = !asset.selected;
                                  setState(() {});
                                },
                                onTap: () {
                                  //Grid is in selction mode
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
                                        : asset.assetEntity!.thumbData,
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
    return Container(
        color: Colors.black,
        child: DraggableScrollbar.semicircle(
            labelTextBuilder: (offset) => getScrollLabel(),
            labelConstraints:
                BoxConstraints.tightFor(width: 150.0, height: 30.0),
            heightScrollThumb: 50.0,
            controller: _scrollController,
            child: _gridView(orientation, assetStore)));
  }

  _syncProgress() {
    return Container(
        color: Colors.black,
        width: double.infinity,
        child: new SyncProcessWidget());
  }

  Future<void> _refreshGrid() async {
    _assetStore.getAssets();
  }

  _getLeadingIcon() {
    if (_assetStore.isAnyItemSelected()) {
      return IconButton(
        onPressed: () {
          _assetStore.assetList.forEach((asset) {
            asset.selected = false;
          });
        },
        icon: Icon(Icons.cancel),
      );
    }
  }

  _body() {
    return Scaffold(
      appBar: AppBar(
        leading: _getLeadingIcon(),
        title: Text(!_assetStore.isAnyItemSelected()
            ? (widget.type == ASSET_TYPE.PHOTO ? "Photos" : "Videos")
            : (_assetStore.getSelectedCount().toString() + " Selected")),
        backgroundColor: Colors.black,
        actions: [
          if (!_assetStore.isAnyItemSelected())
            IconButton(
                onPressed: () {
                  _refreshGrid();
                },
                icon: Icon(Icons.refresh, color: Colors.white)),
          if (_assetStore.isAnyItemSelected())
            IconButton(
                onPressed: () {
                  _shareAsset();
                },
                icon: Icon(Icons.share, color: Colors.white))
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
      body: Column(
        children: <Widget>[
          _syncProgress(),
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
    _assetStore = widget.type == ASSET_TYPE.PHOTO
        ? Provider.of<PhotoStore>(context)
        : Provider.of<VideoStore>(context);

    return _body();
  }
}
