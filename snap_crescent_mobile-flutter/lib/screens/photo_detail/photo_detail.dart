

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/services/photo_service.dart';

class PhotoDetail extends StatelessWidget {

  static const routeName = '/photo_detail';

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo"),
      ),
    body: Column(
          children: <Widget>[Expanded(child: PhotoDetailView())],
        ));        
  }
}

class PhotoDetailView extends StatefulWidget {
  @override
  _PhotoDetailViewState createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  Future<BaseResponseBean<int, Photo>>? getPhotoByIdResponse;

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {

    final routeArgument = ModalRoute.of(context)!.settings.arguments as dynamic;
    getPhotoByIdResponse = PhotoService().getById(routeArgument['id']);
    
    _imageBanner(String _base64EncodedPhoto) {
      return Container(
        constraints: BoxConstraints.expand(
          height: 500.0,
        ),
        decoration: BoxDecoration(color: Colors.grey),
        child: 
        new Image.memory(base64Decode(_base64EncodedPhoto),fit: BoxFit.cover),
        );
    }

    return FutureBuilder<BaseResponseBean<int, Photo>>(
        future: getPhotoByIdResponse,
        builder: (context, searchResponse) {
          if (searchResponse.hasData) {
            final photo = searchResponse.data!.object;

            return GestureDetector(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch, 
                        children : [
                          _imageBanner(photo!.photoMetadata!.base64EncodedPhoto!)
                        ]
                    ));
          } else if (searchResponse.hasError) {
            return Text("${searchResponse.error}");
          }

          // By default, show a loading spinner.
          return Center(
                child: Container(
                  width: 60,
                  height: 60,
                  child: const CircularProgressIndicator(),
                ),
              );
        });
  }
}