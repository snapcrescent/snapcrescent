import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/asset/asset.dart';
import 'package:snapcrescent_mobile/asset/state/asset_state.dart';
import 'package:snapcrescent_mobile/asset/unified_asset.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class AssetThumbnail extends StatefulWidget {
  
  final UniFiedAsset unifiedAsset;
  final Future<Object?> assetThumbnail;
  final bool selected;

  AssetThumbnail(this.unifiedAsset, this.assetThumbnail, this.selected);

  @override
  createState() => _AssetThumbnailState(unifiedAsset, assetThumbnail);
}

class _AssetThumbnailState extends State<AssetThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final UniFiedAsset unifiedAsset;
  final Future<Object?> assetThumbnail;

  _AssetThumbnailState(this.unifiedAsset, this.assetThumbnail);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      value: widget.selected ? 1 : 0,
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void didUpdateWidget(AssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _body(Object object) {
    return Stack(children: [
      AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.grey,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey,
                ),
                child: child,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            if (unifiedAsset.assetSource == AssetSource.CLOUD &&
                object is Asset)
              Positioned.fill(
                child: Image.file(object.thumbnail!.thumbnailFile!,
                    fit: BoxFit.cover),
              )
            else if (unifiedAsset.assetSource == AssetSource.DEVICE &&
                object is Uint8List)
              Positioned.fill(
                child: Image.memory(object, fit: BoxFit.cover),
              ),
            if (unifiedAsset.assetSource == AssetSource.DEVICE &&
                object is Uint8List)
              Positioned.fill(
                child: Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.cloud_off_outlined,
                      color: Colors.grey.shade300,
                    )),
              ),

            // Display a Play icon if the asset is a video
            if ((unifiedAsset.assetSource == AssetSource.CLOUD &&
                    unifiedAsset.asset!.assetType == AppAssetType.VIDEO.id) ||
                (unifiedAsset.assetSource == AssetSource.DEVICE &&
                    unifiedAsset.assetEntity!.type == AssetType.video))
              Positioned.fill(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(DateUtilities().getDurationString(unifiedAsset.duration),
                        style: TextStyle(
                          color: Colors.white,
                        ))),
              ),
            if ((unifiedAsset.assetSource == AssetSource.CLOUD &&
                  unifiedAsset.asset!.assetType == AppAssetType.VIDEO.id) ||
              (unifiedAsset.assetSource == AssetSource.DEVICE &&
                  unifiedAsset.assetEntity!.type == AssetType.video)) 
              Positioned.fill(
                  child: Align(
                alignment: Alignment.topRight,
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
                ),
              ))
          ],
        ),
      ),
      // Display a Circle icon if the asset is not selected

      if (AssetState().isAnyItemSelected() && widget.selected == false)
        Positioned.fill(
          child: Align(
            alignment: Alignment.topLeft,
            child: Icon(
              Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ),
        ),

      // Display a Checked icon if the asset is selected
      if (AssetState().isAnyItemSelected() && widget.selected)
        Positioned.fill(
          child: Align(
              alignment: Alignment.topLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
                child: Container(
                  color: Colors.blue.shade300,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.black,
                  ),
                ),
              )),
        )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: assetThumbnail,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return Container(color: Colors.grey);
        // If there's data, display it as an image
        return _body(bytes);
      },
    );
  }
}
