import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/cloud/grid/asset_detail.dart';
import 'package:snap_crescent/screens/cloud/grid/asset_thumbnail.dart';
import 'package:snap_crescent/stores/asset_store.dart';
import 'package:snap_crescent/stores/photo_store.dart';
import 'package:snap_crescent/stores/video_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetsGridScreen extends StatelessWidget {
  static const routeName = '/assets';

  final ASSET_TYPE type;

  AssetsGridScreen(this.type);

  @override
  Widget build(BuildContext context) {
    return _LocalPhotoGridView(type);
  }
}

class _LocalPhotoGridView extends StatefulWidget {
  final ASSET_TYPE type;

  _LocalPhotoGridView(this.type);

  @override
  _LocalPhotoGridViewState createState() => _LocalPhotoGridViewState();
}

class _LocalPhotoGridViewState extends State<_LocalPhotoGridView> {
  final DragSelectGridViewController _gridViewController =
      DragSelectGridViewController();
  final ScrollController _scrollController = new ScrollController();

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
    _gridViewController.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    _gridViewController.removeListener(scheduleRebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AssetStore assetStore = widget.type == ASSET_TYPE.PHOTO
        ? Provider.of<PhotoStore>(context)
        : Provider.of<VideoStore>(context);

    int getPhotoGroupIndexInScrollView() {
      try {
        final double currentAsset = (assetStore.groupedAssets.length - 1) *
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
      final keys = List.from(assetStore.groupedAssets.keys);
      final label = keys[getPhotoGroupIndexInScrollView()];

      if (label == null) {
        return const Text('');
      }
      return Text(label);
    }

    _gridView(Orientation orientation, AssetStore assetStore) {
      final keys = assetStore.groupedAssets.keys.toList();
      return new ListView.builder(
          controller: _scrollController,
          itemCount: keys.length,
          itemBuilder: (BuildContext ctxt, int groupIndex) {
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
                          child: Text(keys[groupIndex],
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                        DragSelectGridView(
                          gridController: _gridViewController,
                          padding: const EdgeInsets.all(8),
                          itemCount: assetStore
                              .groupedAssets[keys[groupIndex]]!.length,
                          itemBuilder: (context, index, selected) {
                            final asset = assetStore
                                .groupedAssets[keys[groupIndex]]![index];
                            return AssetThumbnail(
                                index, asset, selected, _gridViewController,
                                () {
                              _onAssetTap(
                                  context, assetStore.assetList.indexOf(asset));
                            });
                          },
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          physics:
                              NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                          shrinkWrap: true,
                        )
                      ])
              ],
            );
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

    Future<void> _pullRefresh() async {
      await assetStore.getAssets(true);
      setState(() {});
    }

    _getLeadingIcon() {
      if (_gridViewController.value.amount > 0) {
        return IconButton(
          onPressed: () {
            _gridViewController.clear();
          },
          icon: Icon(Icons.cancel),
        );
      }
    }

    _body() {
      return Scaffold(
        appBar: AppBar(
          leading: _getLeadingIcon(),
          title: Text(_gridViewController.value.amount == 0
              ? (widget.type == ASSET_TYPE.PHOTO ? "Photos" : "Videos")
              : (_gridViewController.value.amount.toString() + " Selected")),
          backgroundColor: Colors.black,
          actions: [
            if (_gridViewController.value.amount > 0)
            IconButton(
                onPressed: () {
                  _shareAsset();
                },
                icon: Icon(Icons.share, color: Colors.white))
          ],
        ),
        drawer: AppDrawer(),
        body: Row(
          children: <Widget>[
            Expanded(
                child: Observer(
                    builder: (context) => assetStore.assetsSearchProgress !=
                            AssetSearchProgress.IDLE
                        ? OrientationBuilder(builder: (context, orientation) {
                            return RefreshIndicator(
                                onRefresh: _pullRefresh,
                                child:
                                    _scrollableView(orientation, assetStore));
                          })
                        : Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              child: const CircularProgressIndicator(),
                            ),
                          )))
          ],
        ),
      );
    }

    return _body();
  }

  void scheduleRebuild() => setState(() {});
}
