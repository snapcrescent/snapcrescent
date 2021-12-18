import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/models/unified_asset.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/stores/asset/video_store.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:video_player/video_player.dart';

class AssetDetailScreen extends StatelessWidget {
  static const routeName = '/asset_detail';

  final AssetDetailArguments _arguments;
  AssetDetailScreen(this._arguments);

  @override
  Widget build(BuildContext context) {
    return _AssetDetailView(_arguments.type, _arguments.assetIndex);
  }
}

class _AssetDetailView extends StatefulWidget {
  final ASSET_TYPE type;
  final int assetIndex;

  _AssetDetailView(this.type, this.assetIndex);

  @override
  _AssetDetailViewState createState() => _AssetDetailViewState();
}

class _AssetDetailViewState extends State<_AssetDetailView> {

  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  PageController? pageController;
  Map<String, String> headers = {};
  String serverUrl = "";
  late AssetStore _assetStore;

  _videoPlayer(UniFiedAsset? unifiedAsset) {
    if (_videoPlayerController == null) {
      if (_videoPlayerController != null) {
        _videoPlayerController!.dispose();
      }

      if (unifiedAsset!.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        String assetURL = AssetService.instance.getAssetByIdUrl(serverUrl, asset.id!);

        _videoPlayerController =
            VideoPlayerController.network(assetURL, httpHeaders: headers)
              ..setLooping(true)
              ..initialize().then((_) {
                setState(() {});
              });
      } else {
        AssetEntity asset = unifiedAsset.assetEntity!;

        asset.file.then(
            (file) => _videoPlayerController = VideoPlayerController.file(file!)
              ..setLooping(true)
              ..initialize().then((_) {
                setState(() {});
              }));
      }
    }

    if(_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: true,
    );
    }

    return _videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized
        ? Container(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ))
        : Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
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
          imageProvider: CachedNetworkImageProvider(
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

  _getAssetFile(int assetIndex) async {
      final UniFiedAsset unifiedAsset = _assetStore.assetList[assetIndex];

      File? assetFile;

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        assetFile = await AssetService.instance
            .downloadAssetById(asset.id!, asset.metadata!.name!);
      } else {
        AssetEntity asset = unifiedAsset.assetEntity!;
        assetFile = await asset.file;
      }

      return assetFile;
    }

    Future<void> _shareAssetFile(int assetIndex) async {
      final File? assetFile = await _getAssetFile(assetIndex);
      String mimeType =
          widget.type == ASSET_TYPE.PHOTO ? "image/jpg" : "video/mp4";
      await Share.shareFiles(<String>[assetFile!.path],
          mimeTypes: <String>[mimeType]);
    }

    _assetView(index) {
      return GestureDetector(
        onLongPress: () {
          setState(() {});
        },
        onTap: () {},
        child: FutureBuilder<Object?>(
            future: Future.value(
                _assetStore.assetList[index].assetSource == AssetSource.CLOUD
                    ? _assetStore.assetList[index].asset
                    : _assetStore.assetList[index].assetEntity!.file),
            builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              if (snapshot.data == null) {
                return Container();
              } else {
                UniFiedAsset asset = _assetStore.assetList[index];
                return widget.type == ASSET_TYPE.PHOTO
                    ? _imageBanner(asset, snapshot.data)
                    : _videoPlayer(asset);
              }
            }),
      );
    }

    _pageView() {
      return Container(
        color: Colors.black,
        child: new Stack(fit: StackFit.expand, children: <Widget>[
          new Scaffold(
            backgroundColor: Colors.transparent,
            body: PageView.builder(
              controller: pageController,
              physics: widget.type == ASSET_TYPE.PHOTO
                  ? PageScrollPhysics()
                  : NeverScrollableScrollPhysics(),
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
                flex: 1,
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
                flex: 1,
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

    _getFloatingActionButton() {
      if (widget.type == ASSET_TYPE.VIDEO) {
        return FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_videoPlayerController != null &&
                  _videoPlayerController!.value.isPlaying) {
                _videoPlayerController!.pause();
              } else {
                _videoPlayerController!.play();
              }
            });
          },
          child: Icon(
            _videoPlayerController != null &&
                    _videoPlayerController!.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
          ),
        );
      } else {
        new Container();
      }
    }

    _body() {
      return Scaffold(
        body: Row(
          children: <Widget>[Expanded(child: _pageView())],
        ),
        //floatingActionButton: _getFloatingActionButton(),
      );
    }

  @override
  Widget build(BuildContext context) {
    
     _assetStore = widget.type == ASSET_TYPE.PHOTO
        ?  Provider.of<PhotoStore>(context)
        : Provider.of<VideoStore>(context);

    return _body();
  }

  @override
  void dispose() {
    pageController!.dispose();

    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }

    if(_chewieController != null) {
      _chewieController!.dispose();
    }

    super.dispose();
  }
}
