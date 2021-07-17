import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/photo_detail/photo_detail.dart';
import 'package:snap_crescent/stores/photo_store.dart';

class PhotoGridScreen extends StatelessWidget {
  static const routeName = '/photo';

  @override
  Widget build(BuildContext context) {
    return _PhotoGridView();
  }
}

class _PhotoGridView extends StatefulWidget {
  @override
  _PhotoGridViewState createState() => _PhotoGridViewState();
}

class _PhotoGridViewState extends State<_PhotoGridView> {
  bool isSelectMode = false;
  List<int> selectedPhotoIndex = [];

  _onPhotoTap(BuildContext context, int photoId) {
    Navigator.pushNamed(
      context,
      PhotoDetailScreen.routeName,
      arguments: photoId,
    );
  }

  _onPhotoLongPress(BuildContext context, int photoId) {
    isSelectMode = !isSelectMode;
    setState(() {
      
    });
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
    final keys = photosStore.groupedPhotos.keys.toList();
    return new ListView.builder(
        itemCount: photosStore.groupedPhotos.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(5), child: Text(keys[index])),
              GridView.count(
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                crossAxisCount: orientation == Orientation.portrait ? 4 : 8,
                physics:
                    NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                shrinkWrap: true,
                children: photosStore.groupedPhotos[keys[index]]!
                    .map((photo) => GestureDetector(
                        child: new Image.memory(base64Decode(
                            photo.thumbnail!.base64EncodedThumbnail!)),
                        onLongPress: () => _onPhotoLongPress(
                            context, photosStore.photoList.indexOf(photo)),
                        onTap: () => _onPhotoTap(
                            context, photosStore.photoList.indexOf(photo))))
                    .toList(),
              )
            ],
          );
        });
  }

  Future<void> _sharePhotoFile() async {
    //final Photo photo = photosStore.photoList[index];
    //final File photoFile = await PhotoService()
    //  .downloadPhotoById(photo.id!, photo.thumbnail!.name!);
    //await Share.shareFiles(<String>[photoFile.path],
    //  mimeTypes: <String>['image/jpg']);
  }

  _sharePhoto(BuildContext context) async {
    await _sharePhotoFile();
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

    _body() {
      return Scaffold(
        appBar: AppBar(
          title: Text('Photos'),
          backgroundColor: Colors.black,
          actions: [
            /*
            IconButton(
                onPressed: () {
                  _downloadPhoto(widget.photoIndex, context);
                },
                icon: Icon(Icons.download, color: Colors.white)),
            */
            if (isSelectMode)
              IconButton(
                  onPressed: () {
                    _sharePhoto(context);
                  },
                  icon: Icon(Icons.share, color: Colors.white))
          ],
        ),
        drawer: AppDrawer(),
        body: Row(
          children: <Widget>[
            Expanded(
                child: Observer(
                    builder: (context) => photosStore.photoList.isNotEmpty
                        ? OrientationBuilder(builder: (context, orientation) {
                            return RefreshIndicator(
                                onRefresh: _pullRefresh,
                                child: _scrollableView(
                                    _gridView(orientation, photosStore)));
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
