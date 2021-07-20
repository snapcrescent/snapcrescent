import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalAssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final Future<Uint8List?> assetThumbnail;

  LocalAssetThumbnail(this.asset, this.assetThumbnail);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: assetThumbnail,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return Stack(
          children: [
            // Wrap the image in a Positioned.fill to fill the space
            Positioned.fill(
              child: Image.memory(bytes, fit: BoxFit.cover),
            ),
            // Display a Play icon if the asset is a video
            if (asset.type == AssetType.video)
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
