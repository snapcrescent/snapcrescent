import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/photo/photo_store.dart';
import 'package:snap_crescent/screens/photo_detail/photo_detail.dart';

class PhotoScreen extends StatelessWidget {
  static const routeName = '/photo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Photos'),
          backgroundColor: Colors.black,
        ),
        drawer: AppDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[Expanded(child: PhotoGridView())],
        ));
  }
}

class PhotoGridView extends StatefulWidget {
  @override
  _PhotoGridViewState createState() => _PhotoGridViewState();
}

class _PhotoGridViewState extends State<PhotoGridView> {
  _onPhotoTap(BuildContext context, int photoId, List<Photo> photos) {
    Navigator.pushNamed(
      context,
      PhotoDetail.routeName,
      arguments: photoId,
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

  _gridView(Orientation orientation, PhotoStore photosStore) {
    return GridView.count(
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      crossAxisCount: orientation == Orientation.portrait ? 4 : 8,
      children: photosStore.allPhotos
          .map((photo) => GestureDetector(
              child: new Image.memory(
                  base64Decode(photo.thumbnail!.base64EncodedThumbnail!)),
              onTap: () =>
                  _onPhotoTap(context, photo.id!, photosStore.allPhotos)))
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PhotoStore photosStore = Provider.of<PhotoStore>(context);

    Future<void> _pullRefresh() async {
      photosStore.getPhotos(true);
      setState(() {});
    }

    return Observer(
        builder: (context) => photosStore.allPhotos.isNotEmpty
            ? OrientationBuilder(builder: (context, orientation) {
                return RefreshIndicator(
                    onRefresh: _pullRefresh,
                    child: _scrollableView(_gridView(orientation, photosStore)));
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
