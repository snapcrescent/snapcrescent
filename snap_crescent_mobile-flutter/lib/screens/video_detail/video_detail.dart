import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/video.dart';
import 'package:snap_crescent/services/video_service.dart';
import 'package:snap_crescent/stores/video_store.dart';
import 'package:video_player/video_player.dart';

class VideoDetailScreen extends StatelessWidget {
  static const routeName = '/video_detail';

  final String _videoIndex;
  VideoDetailScreen(this._videoIndex);

  @override
  Widget build(BuildContext context) {
    return _VideoDetailView(int.parse(_videoIndex));
  }
}

class _VideoDetailView extends StatefulWidget {
  final int videoIndex;

  _VideoDetailView(this.videoIndex);

  @override
  _VideoDetailViewState createState() => _VideoDetailViewState();
}

class _VideoDetailViewState extends State<_VideoDetailView> {
  VideoPlayerController? videoPlayerController;
  PageController? pageController;
  String? _genericVideoByIdUrl;

  _videoPlayer(Video? video) {
    String videoURL =
        VideoService().getVideoByIdUrl(_genericVideoByIdUrl!, video!.id!);

    if (videoPlayerController == null ||
        videoPlayerController!.dataSource != videoURL) {
      if (videoPlayerController != null) {
        videoPlayerController!.dispose();
      }

      videoPlayerController = VideoPlayerController.network(videoURL)
        ..initialize().then((_) {
          setState(() {
            videoPlayerController!.play();
          });
        });
    }

    return videoPlayerController != null &&
            videoPlayerController!.value.isInitialized
        ? Container(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(videoPlayerController!),
            ))
        : Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
  }

  @override
  void initState() {
    super.initState();
    VideoService()
        .getGenericVideoByIdUrl()
        .then((value) => _genericVideoByIdUrl = value);
    pageController = PageController(
      initialPage: widget.videoIndex,
      viewportFraction: 1.06,
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoStore videosStore = Provider.of<VideoStore>(context);

    Future<void> _shareVideoFile(int index) async {
      final Video video = videosStore.videoList[index];
      final File videoFile = await VideoService()
          .downloadVideoById(video.id!, video.thumbnail!.name!);
      await Share.shareFiles(<String>[videoFile.path],
          mimeTypes: <String>['image/jpg']);
    }

    _shareVideo(int index, BuildContext context) async {
      await _shareVideoFile(index);
    }

    _downloadVideo(int index, BuildContext context) async {
      final status = await Permission.storage.request();

      if (status.isGranted) {
        final externalDirectory = await getExternalStorageDirectory();

        final Video video = videosStore.videoList[index];
        await FlutterDownloader.enqueue(
          url: VideoService().getVideoByIdUrl(_genericVideoByIdUrl!, video.id!),
          savedDir: externalDirectory!.path,
          fileName: video.thumbnail!.name,
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)
        );
      } else {
        print("Permissions Denied");
      }
    }

    _videoView(index) {
      return FutureBuilder<Video>(
          future: Future.value(videosStore.videoList[index]),
          builder: (BuildContext context, AsyncSnapshot<Video> snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              return _videoPlayer(snapshot.data);
            }
          });
    }

    _pageView() {
      return Container(
        color: Colors.black,
        child: PageView.builder(
          controller: pageController,
          itemCount: videosStore.videoList.length,
          itemBuilder: (BuildContext context, int index) {
            if (videosStore.videoList.isEmpty) {
              return Container();
            } else {
              return _videoView(index);
            }
          },
        ),
      );
    }

    _body() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            /*
            IconButton(
                onPressed: () {
                  _downloadVideo(widget.videoIndex, context);
                },
                icon: Icon(Icons.download, color: Colors.white)),
            */
            IconButton(
                onPressed: () {
                  _shareVideo(widget.videoIndex, context);
                },
                icon: Icon(Icons.share, color: Colors.white))
          ],
        ),
        body: Row(
          children: <Widget>[Expanded(child: _pageView())],
        ),
      );
    }

    return _body();
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }
}
