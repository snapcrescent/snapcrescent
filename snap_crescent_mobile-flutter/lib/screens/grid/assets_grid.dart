import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/grid/asset_detail.dart';
import 'package:snap_crescent/screens/grid/asset_thumbnail.dart';
import 'package:snap_crescent/stores/cloud/asset_store.dart';
import 'package:snap_crescent/stores/cloud/photo_store.dart';
import 'package:snap_crescent/stores/cloud/video_store.dart';
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
  }

  @override
  void dispose() {
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
                        GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            physics:
                                NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                            shrinkWrap: true,
                            itemCount: assetStore.groupedAssets[keys[groupIndex]]!.length,
                            itemBuilder: (BuildContext ctx, index) {
                              final asset = assetStore
                                  .groupedAssets[keys[groupIndex]]![index];

                              return GestureDetector(
                                onLongPress: () {
                                  asset.selected = !asset.selected;
                                  setState(() {
                                    
                                  });
                                },
                                onTap: () {
                                  //Grid is in selction mode
                                  if(assetStore.isAnyItemSelected()) {
                                        asset.selected = !asset.selected;
                                        setState(() {
                                    
                                  });
                                  } //No asset is selected, proceed to asset detail page 
                                  else {
                                        _onAssetTap(context,assetStore.assetList.indexOf(asset));
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
      
      if (assetStore.isAnyItemSelected()) {
        return IconButton(
          onPressed: () {
            assetStore.assetList.forEach((asset) { asset.selected = false; });
          },
          icon: Icon(Icons.cancel),
        );
      }
      
    }

    _body() {
      return Scaffold(
        appBar: AppBar(
          leading: _getLeadingIcon(),
          title: Text(!assetStore.isAnyItemSelected()
              ? (widget.type == ASSET_TYPE.PHOTO ? "Photos" : "Videos")
              : (assetStore.getSelectedCount().toString() + " Selected")),
              
          backgroundColor: Colors.black,
          actions: [
            
            if (assetStore.isAnyItemSelected())
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
                                child: Stack(children: <Widget>[
                                  _scrollableView(orientation, assetStore)
                                ]));
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