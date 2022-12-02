import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/models/unified_asset.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetDetailScreen extends StatelessWidget {
  static const routeName = '/asset_detail';

  final AssetDetailArguments _arguments;
  AssetDetailScreen(this._arguments);

  @override
  Widget build(BuildContext context) {
    return _AssetDetailView(_arguments.assetIndex);
  }
}

class _AssetDetailView extends StatefulWidget {
  final int assetIndex;

  _AssetDetailView(this.assetIndex);

  @override
  _AssetDetailViewState createState() => _AssetDetailViewState();
}

class _AssetDetailViewState extends State<_AssetDetailView> {
  BetterPlayerController? _betterPlayerController;
  BetterPlayerConfiguration? betterPlayerConfiguration;
  BetterPlayerBufferingConfiguration? bufferingConfiguration;
  PageController? pageController;
  Map<String, String> headers = {};
  String serverUrl = "";

  late AssetStore _assetStore;

  _videoPlayer(UniFiedAsset? unifiedAsset, Object? object) {
    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
    }

    betterPlayerConfiguration = BetterPlayerConfiguration(
      autoPlay: true,
      looping: true,
      expandToFill: false,
      autoDetectFullscreenDeviceOrientation: true,
      fit: BoxFit.contain,
    );

    bufferingConfiguration = BetterPlayerBufferingConfiguration(
      minBufferMs: 50000,
      maxBufferMs: 13107200,
      bufferForPlaybackMs: 10000,
      bufferForPlaybackAfterRebufferMs: 5000,
    );

    _betterPlayerController =
        BetterPlayerController(betterPlayerConfiguration!);

    BetterPlayerDataSource? dataSource;

    if (unifiedAsset!.assetSource == AssetSource.CLOUD) {
      Asset asset = unifiedAsset.asset!;
      String assetURL = AssetService.instance.getAssetByIdUrl(serverUrl, asset.id!);
      

      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        assetURL,
        headers: {
          "range": "bytes=0-",
        },
        bufferingConfiguration: bufferingConfiguration!,
      );
    } else {
      if (object is File) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          object.path,
          bufferingConfiguration: bufferingConfiguration!,
        );
      }
    }

    if (dataSource != null) {
      _betterPlayerController!.setupDataSource(dataSource);
    }

    return Container(
        child: AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _betterPlayerController!),
    ));
  }

  _imageBanner(UniFiedAsset unifiedAsset, Object? object) {
    if (unifiedAsset.assetSource == AssetSource.CLOUD && object is Asset) {
      Asset asset = object;

      return PhotoView(
          loadingBuilder: (context, progress) => Center(
                child: Container(
                  child: Image.file(asset.thumbnail!.thumbnailFile!,
                      fit: BoxFit.fitWidth),
                ),
              ),
          gaplessPlayback: true,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.8,
          imageProvider: NetworkImage(
              AssetService.instance.getAssetByIdUrl(serverUrl, asset.id!),
              headers: headers));
    } else if (unifiedAsset.assetSource == AssetSource.DEVICE &&
        object is File) {
      return Image.file(object);
    }
  }

  @override
  void initState() {
    super.initState();

    AssetService.instance.getHeadersMap().then((value) => {headers = value});
    AssetService.instance.getServerUrl().then((value) => {serverUrl = value});

    pageController = PageController(
      initialPage: widget.assetIndex,
      viewportFraction: 1.06,
    );
  }

  Future<void> _shareAssetFile(int assetIndex) async {
    final List<XFile> assetFiles =
        await _assetStore.getAssetFileForSharing([assetIndex]);
    await Share.shareXFiles(assetFiles);
  }

  _assetView(index) {
    return FutureBuilder<Object?>(
        future: Future.value(
            _assetStore.assetList[index].assetSource == AssetSource.CLOUD
                ? _assetStore.assetList[index].asset
                : _assetStore.assetList[index].assetEntity!.file),
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            UniFiedAsset asset = _assetStore.assetList[index];

            return Container(
                width: 90,
                height: 90,
                child: asset.assetType == AppAssetType.PHOTO
                    ? _imageBanner(asset, snapshot.data)
                    : _videoPlayer(asset, snapshot.data));
          }
        });
  }

  _pageView() {
    return Container(
      color: Colors.black,
      child: new Stack(fit: StackFit.expand, children: <Widget>[
        new Scaffold(
          backgroundColor: Colors.transparent,
          body: PageView.builder(
            controller: pageController,
            physics: PageScrollPhysics(),
            itemCount: _assetStore.assetList.length,
            itemBuilder: (BuildContext context, int index) {
              if (_assetStore.assetList.isEmpty) {
                return Container();
              } else {
                return _assetView(index);
              }
            },
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Container(
                width: 100.0,
                height: 100.0,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                width: 100.0,
                height: 100.0,
                child: IconButton(
                    onPressed: () {
                      _shareAssetFile(widget.assetIndex);
                    },
                    icon: Icon(Icons.share, color: Colors.white)),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  _body() {
    return Scaffold(
        body: Row(
      children: <Widget>[Expanded(child: _pageView())],
    ));
  }

  @override
  Widget build(BuildContext context) {
    _assetStore = Provider.of<AssetStore>(context);

    return _body();
  }

  @override
  void dispose() async {
    super.dispose();
    pageController!.dispose();

    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
    }
  }
}
