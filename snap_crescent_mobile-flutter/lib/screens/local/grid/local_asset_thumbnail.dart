import 'dart:typed_data';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalAssetThumbnail extends StatefulWidget {
  final index;
  final AssetEntity asset;
  final Future<Uint8List?> assetThumbnail;
  final bool selected;
  final Function onTapCallback;
  final DragSelectGridViewController gridController;

  LocalAssetThumbnail(this.index, this.asset, this.assetThumbnail,
      this.selected, this.gridController, this.onTapCallback);

  @override
  _LocalAssetThumbnailState createState() =>
      _LocalAssetThumbnailState(asset, assetThumbnail);
}

class _LocalAssetThumbnailState extends State<LocalAssetThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final AssetEntity asset;
  final Future<Uint8List?> assetThumbnail;

  _LocalAssetThumbnailState(this.asset, this.assetThumbnail);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      value: widget.selected ? 1 : 0,
      duration: kThemeChangeDuration,
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
  void didUpdateWidget(LocalAssetThumbnail oldWidget) {
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

  void onTap() {
    final Selection selection = widget.gridController.value;
    if (selection.isSelecting) {
      final Set<int> selectedIndexes = selection.selectedIndexes.toSet();
      if (selectedIndexes.contains(widget.index)) {
        selectedIndexes.remove(widget.index);
      } else {
        selectedIndexes.add(widget.index);
      }
      widget.gridController.value = Selection(selectedIndexes);
      return;
    }
    widget.onTapCallback();
  }

  _body(Uint8List bytes) {
    return GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Container(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: DecoratedBox(
                  child: child,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
          child: Stack(
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
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
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
