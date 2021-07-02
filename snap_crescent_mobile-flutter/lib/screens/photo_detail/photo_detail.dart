import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/resository/photo_resository.dart';
import 'package:snap_crescent/services/photo_service.dart';

class PhotoDetail extends StatelessWidget {
  static const routeName = '/photo_detail';

  final String _photoId;

  PhotoDetail(this._photoId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Row(
        children: <Widget>[Expanded(child: PhotoDetailView(_photoId))],
      ),
    );
  }
}

class PhotoDetailView extends StatefulWidget {
  final String _photoIdArguement;

  PhotoDetailView(this._photoIdArguement);

  @override
  _PhotoDetailViewState createState() =>
      _PhotoDetailViewState(_photoIdArguement);
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  final String _photoIdArguement;
  int? _photoId;

  _PhotoDetailViewState(this._photoIdArguement) {
    this._photoId = int.parse(_photoIdArguement);
  }

  @observable
  Photo? photo = new Photo();

  _loadPhotoById(int photoId) async {
    if (photoId != 0) {
      photo = new Photo();
      setState(() {});
      final localPhoto = await PhotoResository.instance.findById(photoId);
      photo = Photo.fromMap(localPhoto);
      setState(() {});
      final photoResponse = await PhotoService().getById(photoId);
      photo = photoResponse.object;
      this._photoId = photoId;
      setState(() {});
    }
  }

  _nextPhoto() async {
    final photoId = await PhotoService().findNextById(_photoId!);
    _loadPhotoById(photoId);
  }

  _previousPhoto() async {
    final photoId = await PhotoService().findPreviousById(_photoId!);
    _loadPhotoById(photoId);
  }

  _imageBanner(Photo? photo) {
    String base64EncodedPhoto;
    if (photo != null &&
        photo.photoMetadata != null &&
        photo.photoMetadata!.base64EncodedPhoto != null) {
      base64EncodedPhoto = photo.photoMetadata!.base64EncodedPhoto!;
    } else {
      base64EncodedPhoto = photo!.thumbnail!.base64EncodedThumbnail!;
    }

    return Image.memory(base64Decode(base64EncodedPhoto),
        fit: BoxFit.scaleDown);
  }

  _imageContainer(Photo? photo) {
    return Container(
        color: Colors.black,
        child: ListView(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.80,
                color: Colors.black,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0) {
                      _nextPhoto();
                    } else {
                      _previousPhoto();
                    }
                  },
                  child: Center(child: Container(child: _imageBanner(photo!))),
                ))
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    _loadPhotoById(_photoId!);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
        builder: (context) => photo!.id == _photoId
            ? OrientationBuilder(builder: (context, orientation) {
                return _imageContainer(photo);
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
