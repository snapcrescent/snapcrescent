import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/screens/photo_detail/photo_detail.dart';
import 'package:snap_crescent/screens/photos/photos_store.dart';

class Photos extends StatelessWidget {
  static const routeName = '/photos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Photos'),
        ),
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PhotosStore photosStore = Provider.of<PhotosStore>(context);

    
    
    _onPhotoTap(BuildContext context, int photoId, List<Photo> photos) {
      Navigator.pushNamed(
        context,
        PhotoDetail.routeName,
        arguments: {
          "id": photoId
        },
      );
    }

    _scrollBar(Widget? child) {
      return Scrollbar(
                  thickness: 10,
                  isAlwaysShown: true,
                  radius: Radius.circular(10),
                  showTrackOnHover: true,
                  notificationPredicate: (ScrollNotification notification) {
                    return notification.depth == 0;
                  },
                  child: GestureDetector(
                      child: child),
                );
    }

    _gridView(PhotosStore photosStore) {
      return GridView.count(
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    crossAxisCount: 4,
                    children: photosStore.allPhotos
                        .map((photo) => GestureDetector(
                            child: new Image.memory(base64Decode(
                                photo.thumbnail!.base64EncodedThumbnail!)),
                            onTap: () => _onPhotoTap(
                                context, photo.id!, photosStore.allPhotos)))
                        .toList(),
                  );
    }

    Future<void> _pullRefresh() async {
      photosStore.getPhotos(true);
      setState(() {});
    }

    return Observer(
        builder: (_) => photosStore.allPhotos.isNotEmpty
            ? RefreshIndicator(
                onRefresh: _pullRefresh,
                child: _scrollBar(_gridView(photosStore)))
            : Center(
                child: Container(
                  width: 60,
                  height: 60,
                  child: const CircularProgressIndicator(),
                ),
              ));
  }

  
}
