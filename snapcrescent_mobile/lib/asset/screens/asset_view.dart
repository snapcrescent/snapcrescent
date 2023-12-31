import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/asset/asset.dart';
import 'package:snapcrescent_mobile/asset/asset_service.dart';
import 'package:snapcrescent_mobile/asset/asset_view_arguments.dart';
import 'package:snapcrescent_mobile/asset/state/asset_state.dart';
import 'package:snapcrescent_mobile/asset/unified_asset.dart';
import 'package:snapcrescent_mobile/common/model/base_response_bean.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/permission_utilities.dart';

class AssetViewScreen extends StatelessWidget {
  static const routeName = '/asset_detail';

  final AssetViewArguments _arguments;
  AssetViewScreen(this._arguments);

  @override
  Widget build(BuildContext context) {
    return _AssetViewView(_arguments.assetIndex);
  }
}

class _AssetViewView extends StatefulWidget {
  final int assetIndex;

  _AssetViewView(this.assetIndex);

  @override
  _AssetViewViewState createState() => _AssetViewViewState();
}

class _AssetViewViewState extends State<_AssetViewView> {
  BetterPlayerController? _betterPlayerController;
  BetterPlayerConfiguration? betterPlayerConfiguration;
  BetterPlayerBufferingConfiguration? bufferingConfiguration;
  PageController? pageController;
  Map<String, String> headers = {};
  String? serverUrl = "";
  bool showProcessing = false;
  UniFiedAsset? currentAsset;

  _videoPlayer(UniFiedAsset? unifiedAsset, Object? object) {
    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
    }

    betterPlayerConfiguration = BetterPlayerConfiguration(
      autoPlay: true,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        showControlsOnInitialize: false,
        controlBarColor: Colors.transparent,
        progressBarPlayedColor:Colors.teal
        ),
      looping: true,
      expandToFill: false,
      autoDetectFullscreenDeviceOrientation: true,
      fit: BoxFit.contain,
    );

    bufferingConfiguration = BetterPlayerBufferingConfiguration(
      minBufferMs: 10000,
      maxBufferMs: 13107200,
      bufferForPlaybackMs: 500,
      bufferForPlaybackAfterRebufferMs: 5000,
    );

    _betterPlayerController =
        BetterPlayerController(betterPlayerConfiguration!);

    BetterPlayerDataSource? dataSource;

    if (unifiedAsset!.assetSource == AssetSource.CLOUD) {
      Asset asset = unifiedAsset.asset!;
      String assetURL =
          AssetService().streamAssetByIdUrl(serverUrl, asset.token!);

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

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _betterPlayerController!),
    );
  }

  _imageBanner(UniFiedAsset unifiedAsset, Object? object) {
    if (unifiedAsset.assetSource == AssetSource.CLOUD && object is Asset) {
      Asset asset = object;

      return PhotoView(
          loadingBuilder: (context, progress) => Center(
                child: Image.file(asset.thumbnail!.thumbnailFile!,
                      fit: BoxFit.fitWidth),
              ),
          gaplessPlayback: true,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.8,
          imageProvider: NetworkImage(
              AssetService().streamAssetByIdUrl(serverUrl, asset.token!),
              headers: headers));
    } else if (unifiedAsset.assetSource == AssetSource.DEVICE &&
        object is File) {
      return Image.file(object);
    }
  }

  @override
  void initState() {
    super.initState();

    AssetService().getHeadersMap().then((value) => {headers = value});
    AssetService().getServerUrl().then((value) => {serverUrl = value});

    pageController = PageController(
      initialPage: widget.assetIndex,
      viewportFraction: 1.06,
    );
  }

  Future<void> _shareAssetFile(int assetIndex) async {
    _updateProcessingBarVisibility(true);
    final List<XFile> assetFiles =
        await AssetService().getAssetFilesForSharing([assetIndex]);
    await Share.shareXFiles(assetFiles);
    _updateProcessingBarVisibility(false);
  }

  Future<void> _downloadAsset(int assetIndex) async {
    _updateProcessingBarVisibility(true);
    bool permissionReady = await PermissionUtilities().checkAndAskForPhotosPermission();

    if (permissionReady) {
      final bool success =
          await AssetService().downloadAssetFilesToDevice([assetIndex]);
      if (success) {
        ToastService.showSuccess("Successfully downloaded files.");
      }
    }
    _updateProcessingBarVisibility(false);
  }

  _uploadAsset(int assetIndex) async {
    bool permissionReady = await PermissionUtilities().checkAndAskForPhotosPermission();

    if (permissionReady) {
      _updateProcessingBarVisibility(true);
      final bool success = await AssetService()
          .uploadAssetFilesToServer([assetIndex]);
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

  _assetView(index) {
    return FutureBuilder<Object?>(
        future: Future.value(
            AssetState().assetList[index].assetSource == AssetSource.CLOUD
                ? AssetState().assetList[index].asset
                : AssetState().assetList[index].assetEntity!.file),
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          
          if (snapshot.data == null) {
            return Container();
          } else {
            currentAsset = AssetState().assetList[index];

            if(currentAsset!.assetSource == AssetSource.DEVICE) {
                return SizedBox(
                width: 90,
                height: 90,
                child: currentAsset!.assetType == AppAssetType.PHOTO
                    ? _imageBanner(currentAsset!, snapshot.data)
                    : _videoPlayer(currentAsset!, snapshot.data));
            } else {
              return FutureBuilder<Object?>(
                future: Future.value(_getAssetById(index)),
                builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {

                  if (snapshot.data == null) {
                    return Container();
                  } else {

                  return SizedBox(
                    width: 90,
                    height: 90,
                    child: currentAsset!.assetType == AppAssetType.PHOTO
                        ? _imageBanner(currentAsset!, snapshot.data)
                        : _videoPlayer(currentAsset!, snapshot.data));
                  }
                }
              );
            }            
          }
        });
  }

  _getAssetById (int index) async {
      BaseResponseBean<int, Asset> response = await AssetService().getAssetById(AssetState().assetList[index].asset!.id!);
      AssetState().assetList[index].asset!.token = response.object!.token!;
      return AssetState().assetList[index].asset;
  }

  _pageView() {
    return Container(
      color: Colors.black,
      child: Stack(fit: StackFit.expand, children: <Widget>[
        Scaffold(
          backgroundColor: Colors.transparent,
          body: PageView.builder(
            controller: pageController,
            physics: PageScrollPhysics(),
            itemCount: AssetState().assetList.length,
            itemBuilder: (BuildContext context, int index) {
              if (AssetState().assetList.isEmpty) {
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
              child: SizedBox(
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
              child: SizedBox(
                width: 200.0,
                height: 100.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      
                        IconButton(
                            disabledColor: Colors.grey,
                            onPressed: () {
                              if(!showProcessing) {
                                _uploadAsset(widget.assetIndex);
                              } else{
                                return;
                              }
                            },
                            icon: Icon(Icons.upload, color: Colors.white)),
                      
                        IconButton(
                            disabledColor: Colors.grey,
                            onPressed: () {
                              if(!showProcessing) {
                                _downloadAsset(widget.assetIndex);
                              } else{
                                return;
                              }
                            },
                            icon: Icon(Icons.download, color: Colors.white)),
                      IconButton(
                          onPressed: () {
                            if(!showProcessing) {
                                _shareAssetFile(widget.assetIndex);
                            } else{
                              return;
                            }
                          },
                          icon: Icon(Icons.share, color: Colors.white))
                    ],
                  ),
              ),
            ),
          ],
        )
      ]),
    );
  }

  _body() {
    return Scaffold(
      body: Column(
        children: [
          if(showProcessing) 
            Expanded(flex:0, child: SizedBox( height: 2,child: const LinearProgressIndicator(),)),
          Expanded(child : _pageView()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
