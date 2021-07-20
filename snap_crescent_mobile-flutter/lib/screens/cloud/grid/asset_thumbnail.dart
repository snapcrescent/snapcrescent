import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetThumbnail extends StatelessWidget {
  final Asset asset;
  
  AssetThumbnail(this.asset);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Future.value(asset.thumbnail!.base64EncodedThumbnail),
      builder: (context, snapshot) {
        final base64EncodedThumbnail = snapshot.data;
        // If we have no data, display a spinner
        if (base64EncodedThumbnail == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return Stack(
          children: [
            // Wrap the image in a Positioned.fill to fill the space
            Positioned.fill(
              child: Image.memory(base64Decode(base64EncodedThumbnail), fit: BoxFit.cover),
            ),
            // Display a Play icon if the asset is a video
            if (asset.assetType == ASSET_TYPE.VIDEO.index)
              Center(
                  child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
                child: Container(
                  color: Colors.grey,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              )),
          ],
        );
      },
    );
  }
}
