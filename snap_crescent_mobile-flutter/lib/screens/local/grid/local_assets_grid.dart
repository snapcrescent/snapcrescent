import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/local_assets_detail_arguments.dart';
import 'package:snap_crescent/models/local_assets_grid_arguments.dart';
import 'package:snap_crescent/screens/local/grid/asset_thumbnail.dart';
import 'package:snap_crescent/screens/local/grid/local_asset_detail.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/stores/local_asset_store.dart';
import 'package:snap_crescent/stores/local_photo_store.dart';
import 'package:snap_crescent/stores/local_video_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class LocalAssetsGridScreen extends StatelessWidget {
  static const routeName = '/local_assets';

  final LocalAssetsGridArguments arguments;

  LocalAssetsGridScreen(this.arguments);

  @override
  Widget build(BuildContext context) {
    return _LocalPhotoGridView(arguments.type,arguments.folderName);
  }
}

class _LocalPhotoGridView extends StatefulWidget {
  final String folderName;
  final ViewType type;

  _LocalPhotoGridView(this.type,this.folderName);

  @override
  _LocalPhotoGridViewState createState() => _LocalPhotoGridViewState();
}

class _LocalPhotoGridViewState extends State<_LocalPhotoGridView> {
  _onAssetTap(BuildContext context, int assetIndex) {

      LocalAssetsDetailArguments arguments = new LocalAssetsDetailArguments(type: widget.type, assetIndex : assetIndex);
   
      Navigator.pushNamed(
      context,
      LocalAssetDetailScreen.routeName,
      arguments: arguments,
    );
    
  }

  _onAssetLongPress(BuildContext context, int photoId) {
    setState(() {});
  }

  _gridView(Orientation orientation, LocalAssetStore localAssetStore) {
    return new ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext ctxt, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (localAssetStore.groupedAssets[widget.folderName]!.length > 0)
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5), child: Text(widget.folderName)),
                      GridView.count(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        crossAxisCount:
                            orientation == Orientation.portrait ? 4 : 8,
                        physics:
                            NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                        shrinkWrap: true,
                        children: localAssetStore.groupedAssets[widget.folderName]!
                            .map((asset) => GestureDetector(
                                child: new AssetThumbnail(asset, asset.thumbData),
                                onLongPress: () => _onAssetLongPress(context,
                                    localAssetStore.assetList.indexOf(asset)),
                                onTap: () => _onAssetTap(context,
                                    localAssetStore.assetList.indexOf(asset))))
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
    final LocalAssetStore localAssetStore = widget.type == ViewType.PHOTO ? Provider.of<LocalPhotoStore>(context) : Provider.of<LocalVideoStore>(context);

    _body() {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.folderName),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  _shareAsset(context);
                },
                icon: Icon(Icons.share, color: Colors.white))
          ],
        ),
        body: Row(
          children: <Widget>[
            Expanded(
                child: Observer(
                    builder: (context) => localAssetStore.groupedAssets.isNotEmpty
                        ? OrientationBuilder(builder: (context, orientation) {
                            return _gridView(orientation, localAssetStore);
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
