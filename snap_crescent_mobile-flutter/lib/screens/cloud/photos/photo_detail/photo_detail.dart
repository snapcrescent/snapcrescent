import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/stores/photo_store.dart';

class PhotoDetailScreen extends StatelessWidget {
  static const routeName = '/photo_detail';

  final String _photoIndex;
  PhotoDetailScreen(this._photoIndex);

  @override
  Widget build(BuildContext context) {
    return _PhotoDetailView(int.parse(_photoIndex));
  }
}

class _PhotoDetailView extends StatefulWidget {
  final int photoIndex;

  _PhotoDetailView(this.photoIndex);

  @override
  _PhotoDetailViewState createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<_PhotoDetailView> {
  PageController? pageController;
  String? _genericPhotoByIdUrl;

  _imageBanner(Photo? photo) {
    String base64EncodedPhoto;
    if (photo != null &&
        photo.photoMetadata != null &&
        photo.photoMetadata!.base64EncodedPhoto != null) {
      base64EncodedPhoto = photo.photoMetadata!.base64EncodedPhoto!;
    } else {
      base64EncodedPhoto = photo!.thumbnail!.base64EncodedThumbnail!;
    }

    return PhotoView(
        loadingBuilder: (context, progress) => Center(
              child: Container(
                child: Image.memory(base64Decode(base64EncodedPhoto),
                    fit: BoxFit.scaleDown),
              ),
            ),
        imageProvider: CachedNetworkImageProvider(
            PhotoService().getPhotoByIdUrl(_genericPhotoByIdUrl!, photo.id!)));
  }

  @override
  void initState() {
    super.initState();
    PhotoService()
        .getGenericPhotoByIdUrl()
        .then((value) => _genericPhotoByIdUrl = value);
    pageController = PageController(
      initialPage: widget.photoIndex,
      viewportFraction: 1.06,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PhotoStore photosStore = Provider.of<PhotoStore>(context);

    Future<void> _sharePhotoFile(int index) async {
      final Photo photo = photosStore.photoList[index];
      final File photoFile = await PhotoService()
          .downloadPhotoById(photo.id!, photo.thumbnail!.name!);
      await Share.shareFiles(<String>[photoFile.path],
          mimeTypes: <String>['image/jpg']);
    }

    _sharePhoto(int index, BuildContext context) async {
      await _sharePhotoFile(index);
    }

    _photoView(index) {
      return FutureBuilder<Photo>(
          future: Future.value(photosStore.photoList[index]),
          builder: (BuildContext context, AsyncSnapshot<Photo> snapshot) {
            if (snapshot.data == null) {
              return Container();
            } else {
              return _imageBanner(snapshot.data);
            }
          });
    }

    _pageView() {
      return Container(
        color: Colors.black,
        child: PageView.builder(
          controller: pageController,
          itemCount: photosStore.photoList.length,
          itemBuilder: (BuildContext context, int index) {
            if (photosStore.photoList.isEmpty) {
              return Container();
            } else {
              return _photoView(index);
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
            IconButton(
                onPressed: () {
                  _sharePhoto(widget.photoIndex, context);
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
    pageController!.dispose();
    super.dispose();
  }
}
