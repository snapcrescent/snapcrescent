import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/stores/local/local_asset_store.dart';
import 'package:snap_crescent/stores/local/local_photo_store.dart';
import 'package:snap_crescent/stores/local/local_video_store.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:video_player/video_player.dart';

class LocalAssetDetailScreen extends StatelessWidget {
  static const routeName = '/local_asset_detail';

  final AssetDetailArguments _arguments;
  LocalAssetDetailScreen(this._arguments);

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
  bool _updateVideoPlayerControllerSource = false;
  int _currentAssetIndex = 0;
  
  _videoPlayer(File? videoFile) {
    if (_videoPlayerController == null || _updateVideoPlayerControllerSource == true) {
      _updateVideoPlayerControllerSource = false;
      if (_videoPlayerController != null) {
        _videoPlayerController!.dispose();
      }

      _videoPlayerController = VideoPlayerController.file(videoFile!)
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {
            
          });
        });
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
  
  _imageBanner(File? asset) {
    if (asset != null) {
      return Image.file(asset);  
    } else {
      return Container();
    }

    
  }

  @override
  void initState() {
    super.initState();
    _currentAssetIndex = widget.assetIndex;
    pageController = PageController(
      initialPage: widget.assetIndex,
      viewportFraction: 1.06,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LocalAssetStore localAssetStore = widget.type == ASSET_TYPE.PHOTO ? Provider.of<LocalPhotoStore>(context) : Provider.of<LocalVideoStore>(context);

    _getAssetFile(int assetIndex) async{
       final AssetEntity asset = localAssetStore.assetList[assetIndex];
      final File? assetFile = await asset.file;
      return assetFile;
    }

    _uploadAsset(int assetIndex, BuildContext context) async {
      ToastService.showSuccess((widget.type == ASSET_TYPE.PHOTO ? "Photo" : "Video") + " upload in Progress");
      final File? assetFile = await _getAssetFile(assetIndex);

      if(widget.type == ASSET_TYPE.PHOTO) {
        await AssetService().save(ASSET_TYPE.PHOTO, [assetFile!]);
      } else{
        await AssetService().save(ASSET_TYPE.VIDEO, [assetFile!]);
      }
      
      ToastService.showSuccess((widget.type == ASSET_TYPE.PHOTO ? "Photo" : "Video") + " uploaded successfully");
    }

    Future<void> _shareAssetFile(int assetIndex) async {
      final File? assetFile = await _getAssetFile(assetIndex);
      await Share.shareFiles(<String>[assetFile!.path],
        mimeTypes: <String>['image/jpg']);
    }

    _assetView(index) {
      return FutureBuilder<File?>(
          future: Future.value(localAssetStore.assetList[index].file),
          builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              return widget.type == ASSET_TYPE.PHOTO ? _imageBanner(snapshot.data) : _videoPlayer(snapshot.data);
            }
          });
    }

    _pageView() {
      return Container(
        color: Colors.black,
        child: PageView.builder(
          controller: pageController,
          // physics: widget.type == ASSET_TYPE.PHOTO ?  PageScrollPhysics() : NeverScrollableScrollPhysics(),
          itemCount: localAssetStore.assetList.length,
          onPageChanged: (index) {
            _videoPlayerController!.pause();
            _updateVideoPlayerControllerSource = true;
            _currentAssetIndex = index;
            setState(() {
              
            });
          },
          itemBuilder: (BuildContext context, int index) {
            if (localAssetStore.assetList.isEmpty) {
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
                  _uploadAsset(_currentAssetIndex, context);
                },
                icon: Icon(Icons.upload, color: Colors.white)),
            
            IconButton(
                onPressed: () {
                  _shareAssetFile(_currentAssetIndex);
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
