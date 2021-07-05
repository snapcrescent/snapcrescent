import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/services/photo_service.dart';
import 'package:snap_crescent/stores/photo_store.dart';

class PhotoDetail extends StatelessWidget {
  static const routeName = '/photo_detail';

  final String _photoIndex;
  PhotoDetail(this._photoIndex);

  @override
  Widget build(BuildContext context) {
    return PhotoDetailView(int.parse(_photoIndex));
  }
}

class PhotoDetailView extends StatefulWidget {
  final int photoIndex;

  PhotoDetailView(this.photoIndex);

  @override
  _PhotoDetailViewState createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
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

    _downloadPhoto(int index, BuildContext context) async {
      final status = await Permission.storage.request();

      if (status.isGranted) {

        final externalDirectory = await getExternalStorageDirectory();

        final Photo photo = photosStore.photoList[index];
        await FlutterDownloader.enqueue(
          url: PhotoService().getPhotoByIdUrl(_genericPhotoByIdUrl!, photo.id!),
          savedDir:externalDirectory!.path,
          fileName: photo.thumbnail!.name,
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)
        );
      } else {
        print("Permissions Denied");
      }
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
            /*
            IconButton(
                onPressed: () {
                  _downloadPhoto(widget.photoIndex, context);
                },
                icon: Icon(Icons.download, color: Colors.white)),
            */
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
}
