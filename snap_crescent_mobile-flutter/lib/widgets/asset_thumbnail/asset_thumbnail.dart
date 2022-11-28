import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/unified_asset.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/stores/asset/photo_store.dart';
import 'package:snap_crescent/utils/constants.dart' as AppConstants;

class AssetThumbnail extends StatefulWidget {
  final index;
  final UniFiedAsset unifiedAsset;
  final Future<Object?> assetThumbnail;
  final bool selected;
  
  AssetThumbnail(this.index, this.unifiedAsset, this.assetThumbnail, this.selected);

  @override
  _AssetThumbnailState createState() =>
      _AssetThumbnailState(unifiedAsset, assetThumbnail);
}

class _AssetThumbnailState extends State<AssetThumbnail> with SingleTickerProviderStateMixin {
  
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final UniFiedAsset unifiedAsset;
  final Future<Object?> assetThumbnail;
  late AssetStore _assetStore;

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
                    child: child,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                if(unifiedAsset.assetSource == AppConstants.AssetSource.CLOUD && object is Asset) 
                  Positioned.fill(
                  child: Image.file(object.thumbnail!.thumbnailFile!,
                      fit: BoxFit.cover),
                  )
                else if(unifiedAsset.assetSource == AppConstants.AssetSource.DEVICE && object is Uint8List) 
                  Positioned.fill(
                  child: Image.memory(object, fit: BoxFit.cover),
                ),


              if(unifiedAsset.assetSource == AppConstants.AssetSource.DEVICE && object is Uint8List) 
                Positioned.fill(
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                            Icons.cloud_off_outlined,
                            color: Colors.grey.shade300,
                          )
                      ),
                ),
                
                // Display a Play icon if the asset is a video
                if ((unifiedAsset.assetSource == AppConstants.AssetSource.CLOUD && unifiedAsset.asset!.assetType == AppConstants.AppAssetType.VIDEO.id )
                     || (unifiedAsset.assetSource == AppConstants.AssetSource.DEVICE && unifiedAsset.assetEntity!.type == AssetType.video))
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
            ),
          ),
          // Display a Circle icon if the asset is not selected
          
          if (_assetStore.isAnyItemSelected() && 
              widget.selected == false)
            Positioned.fill(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      child: Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.white,
                      ),
                    )),
            ),
            
          // Display a Checked icon if the asset is selected
          if (_assetStore.isAnyItemSelected() && widget.selected)
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

    _assetStore = Provider.of<PhotoStore>(context);

        
    return FutureBuilder<Object?>(
      future: assetThumbnail,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return _body(bytes);
      },
    );
  }
}
