import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/video_detail/video_detail.dart';
import 'package:snap_crescent/stores/video_store.dart';

class VideoGridScreen extends StatelessWidget {
  static const routeName = '/video';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Videos'),
          backgroundColor: Colors.black,
        ),
        drawer: AppDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[Expanded(child: VideoGridView())],
        ));
  }
}

class VideoGridView extends StatefulWidget {
  @override
  _VideoGridViewState createState() => _VideoGridViewState();
}

class _VideoGridViewState extends State<VideoGridView> {
  _onVideoTap(BuildContext context, int videoId) {
    Navigator.pushNamed(
      context,
      VideoDetailScreen.routeName,
      arguments: videoId,
    );
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

  _gridView(Orientation orientation, VideoStore videosStore) {
    return GridView.count(
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      crossAxisCount: orientation == Orientation.portrait ? 4 : 8,
      children: videosStore.videoList
          .map((video) => 
           
          GestureDetector(
              child: new Image.memory(
                  base64Decode(video.thumbnail!.base64EncodedThumbnail!)),
              onTap: () =>
                  _onVideoTap(context, videosStore.videoList.indexOf(video)))
          )
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final VideoStore videosStore = Provider.of<VideoStore>(context);

    Future<void> _pullRefresh() async {
      videosStore.getVideos(true);
      setState(() {});
    }

    return Observer(
        builder: (context) => videosStore.videoList.isNotEmpty
            ? OrientationBuilder(builder: (context, orientation) {
                return RefreshIndicator(
                    onRefresh: _pullRefresh,
                    child: _scrollableView(_gridView(orientation, videosStore)));
              })
            : Center(
                child: Container(
                  width: 60,
                  height: 60,
                  child: const CircularProgressIndicator(),
                ),
              ));
  }
}