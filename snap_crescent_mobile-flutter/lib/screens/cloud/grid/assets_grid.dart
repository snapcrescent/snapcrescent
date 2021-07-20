import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
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
  _onAssetTap(BuildContext context, int assetIndex) {
    AssetDetailArguments arguments =
        new AssetDetailArguments(type: widget.type, assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      AssetDetailScreen.routeName,
      arguments: arguments,
    );
  }

  _onAssetLongPress(BuildContext context, int photoId) {
    setState(() {});
  }

  _scrollableView(Widget? child) {
    return Scrollbar(
      thickness: 10,
      isAlwaysShown: true,
      radius: Radius.circular(10),
      showTrackOnHover: true,
      notificationPredicate: (ScrollNotification notification) {
        return notification.depth == 0;
      },
      child: GestureDetector(child: child),
    );
  }

  _gridView(Orientation orientation, AssetStore assetStore) {
    final keys = assetStore.groupedAssets.keys.toList();
    return new ListView.builder(
        itemCount: keys.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (assetStore.groupedAssets[keys[index]]!.length > 0)
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5), child: Text(keys[index])),
                      GridView.count(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        crossAxisCount:
                            orientation == Orientation.portrait ? 4 : 8,
                        physics:
                            NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                        shrinkWrap: true,
                        children: assetStore.groupedAssets[keys[index]]!
                            .map((asset) => GestureDetector(
                                child: new AssetThumbnail(asset),
                                onLongPress: () => _onAssetLongPress(context,
                                    assetStore.assetList.indexOf(asset)),
                                onTap: () => _onAssetTap(context,
                                    assetStore.assetList.indexOf(asset))))
                            .toList(),
                      )
                    ])
            ],
          );
        });
  }

  _shareAsset(BuildContext context) async {
    //await _shareFile();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AssetStore assetStore = widget.type == ASSET_TYPE.PHOTO
        ? Provider.of<PhotoStore>(context)
        : Provider.of<VideoStore>(context);

    Future<void> _pullRefresh() async {
      assetStore.getAssets(true);
      setState(() {});
    }

    _body() {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.type == ASSET_TYPE.PHOTO ? "Photos" : "Videos"),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  _shareAsset(context);
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
                            AssetSearchProgress.SEARCHING
                        ? OrientationBuilder(builder: (context, orientation) {
                            return RefreshIndicator(
                                onRefresh: _pullRefresh,
                                child: _scrollableView(
                                    _gridView(orientation, assetStore)));
                            ;
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
}
