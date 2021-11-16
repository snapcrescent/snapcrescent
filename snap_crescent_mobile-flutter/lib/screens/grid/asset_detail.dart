import 'dart:convert';
import 'dart:io';

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
import 'package:snap_crescent/stores/cloud/asset_store.dart';
import 'package:snap_crescent/stores/cloud/photo_store.dart';
import 'package:snap_crescent/stores/cloud/video_store.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:video_player/video_player.dart';

class AssetDetailScreen extends StatelessWidget {
  static const routeName = '/asset_detail';

  final AssetDetailArguments _arguments;
  AssetDetailScreen(this._arguments);

  @override
  Widget build(BuildContext context) {
    return _LocalPhotoDetailView(_arguments.type,_arguments.assetIndex);
  }
}

class _LocalPhotoDetailView extends StatefulWidget {
  
  final ASSET_TYPE type;
  final int assetIndex;

  _LocalPhotoDetailView(this.type, this.assetIndex);

  @override
  _LocalPhotoDetailViewState createState() => _LocalPhotoDetailViewState();
}

class _LocalPhotoDetailViewState extends State<_LocalPhotoDetailView> {
  
  VideoPlayerController? _videoPlayerController;
  PageController? pageController;
  String? _genericAssetByIdUrl;
  
  _videoPlayer(UniFiedAsset? unifiedAsset) {

      if (_videoPlayerController == null) {
          if (_videoPlayerController != null) {
            _videoPlayerController!.dispose();
          }

          if(unifiedAsset!.assetSource == AssetSource.CLOUD) {
              Asset asset = unifiedAsset.asset!;
              String assetURL = AssetService().getAssetByIdUrl(_genericAssetByIdUrl!, asset.id!);

              _videoPlayerController = VideoPlayerController.network(assetURL)
                ..setLooping(true)
                ..initialize().then((_) {
                  setState(() {

                  });
                });
            } else {

              AssetEntity asset = unifiedAsset.assetEntity!;

              asset.file.then((file) => _videoPlayerController = VideoPlayerController.file(file!)
                  ..setLooping(true)
                  ..initialize().then((_) {
                    setState(() {
                      
                    });
                  }));
              
      
              
            }
            
    } 

    return _videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized
        ? Container(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ))
        : Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
      
  }
  
  _imageBanner(UniFiedAsset unifiedAsset, Object? object) {

    if(unifiedAsset.assetSource == AssetSource.CLOUD && object is Asset) {

      Asset asset = object;
      String base64EncodedPhoto;

      if (asset.metadata != null &&
          asset.metadata!.base64EncodedPhoto != null) {
        base64EncodedPhoto = asset.metadata!.base64EncodedPhoto!;
      } else {
        base64EncodedPhoto = asset.thumbnail!.base64EncodedThumbnail!;
      }

      return PhotoView(
          loadingBuilder: (context, progress) => Center(
                child: Container(
                  child: Image.memory(base64Decode(base64EncodedPhoto),
                      fit: BoxFit.scaleDown),
                ),
              ),
          imageProvider: CachedNetworkImageProvider(
              AssetService().getAssetByIdUrl(_genericAssetByIdUrl!, asset.id!)));

    } else if(unifiedAsset.assetSource == AssetSource.DEVICE && object is File){
      return Image.file(object);
    }
  }

  @override
  void initState() {
    super.initState();

    AssetService()
        .getGenericAssetByIdUrl()
        .then((value) => _genericAssetByIdUrl = value);
    
    pageController = PageController(
      initialPage: widget.assetIndex,
      viewportFraction: 1.06,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AssetStore assetStore = widget.type == ASSET_TYPE.PHOTO ? Provider.of<PhotoStore>(context) : Provider.of<VideoStore>(context);

    _getAssetFile(int assetIndex) async{
      final UniFiedAsset unifiedAsset = assetStore.assetList[assetIndex];

      File? assetFile;

      if(unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        assetFile = await AssetService().downloadAssetById(asset.id!, asset.metadata!.name!);
      } else {
        AssetEntity asset = unifiedAsset.assetEntity!;
        assetFile = await asset.file;
      }
       
      return assetFile;
    }

    Future<void> _shareAssetFile(int assetIndex) async {
      final File? assetFile = await _getAssetFile(assetIndex);
      String mimeType = widget.type == ASSET_TYPE.PHOTO ? "image/jpg" : "video/mp4";
      await Share.shareFiles(<String>[assetFile!.path],mimeTypes: <String>[mimeType]);
    }

    _assetView(index) {
      
      return FutureBuilder<Object?>(
          future: Future.value(assetStore.assetList[index].assetSource == AssetSource.CLOUD ? assetStore.assetList[index].asset : assetStore.assetList[index].assetEntity!.file),
          builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              UniFiedAsset asset = assetStore.assetList[index];
              return widget.type == ASSET_TYPE.PHOTO ? _imageBanner(asset, snapshot.data) : _videoPlayer(asset);
            }
          });
          
    }

    _pageView() {
      return Container(
        color: Colors.black,
        child: PageView.builder(
          controller: pageController,
          physics: widget.type == ASSET_TYPE.PHOTO ?  PageScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: assetStore.assetList.length,
          itemBuilder: (BuildContext context, int index) {
            if (assetStore.assetList.isEmpty) {
              return Container();
            } else {
              return _assetView(index);
            }
          },
        ),
      );
    }

    _getFloatingActionButton() {
      if(widget.type == ASSET_TYPE.VIDEO) {
        return FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_videoPlayerController!= null && _videoPlayerController!.value.isPlaying) {
                _videoPlayerController!.pause();
              } else {
                _videoPlayerController!.play();
              }
            });
          },
          child: Icon(
            _videoPlayerController!= null && _videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        );
      }else{
        new Container();
      }
    }

    _body() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  _shareAssetFile(widget.assetIndex);
                },
                icon: Icon(Icons.share, color: Colors.white))
          ],
        ),
        body: Row(
          children: <Widget>[Expanded(child: _pageView())],
        ),
        floatingActionButton: _getFloatingActionButton(),
      );
    }

    return _body();
  }

  @override
  void dispose() {
    pageController!.dispose();

    if(_videoPlayerController!= null) {
        _videoPlayerController!.dispose();
    }

    super.dispose();
  }
}
