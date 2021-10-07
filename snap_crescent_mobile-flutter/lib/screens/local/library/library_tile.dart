import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/stores/local_asset_store.dart';
import 'package:snap_crescent/stores/local_photo_store.dart';
import 'package:snap_crescent/stores/local_video_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class LibraryTile extends StatelessWidget {
  final ASSET_TYPE type;
  final String folderName;

  LibraryTile(this.type, this.folderName);

  @override
  Widget build(BuildContext context) {
    final LocalAssetStore localAssetStore = this.type == ASSET_TYPE.PHOTO
        ? Provider.of<LocalPhotoStore>(context)
        : Provider.of<LocalVideoStore>(context);

    return FutureBuilder<Uint8List?>(
      future: localAssetStore.groupedAssets[folderName]!.first.thumbData,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return Container(
          margin: EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, // add this
                  children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                    ),
                    child: Positioned.fill(
                        child: Image.memory(bytes,
                            height: 125, width: 125, fit: BoxFit.cover)),
                  ),
                ),
                Text(folderName)
              ]),
        );
      },
    );
  }
}
