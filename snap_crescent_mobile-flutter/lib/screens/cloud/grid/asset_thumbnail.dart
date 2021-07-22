import 'dart:convert';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetThumbnail extends StatefulWidget {
  final index;
  final Asset asset;
  final bool selected;
  final Function onTapCallback;
  final DragSelectGridViewController gridController;

  AssetThumbnail(this.index, this.asset, this.selected, this.gridController,
      this.onTapCallback);

  @override
  _AssetThumbnailState createState() => _AssetThumbnailState(asset);
}

class _AssetThumbnailState extends State<AssetThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final Asset asset;

  _AssetThumbnailState(this.asset);

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

  _body(Asset asset) {
    return GestureDetector(
        onTap: onTap,
        child: Stack(children: [
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
                // Wrap the image in a Positioned.fill to fill the space
                Positioned.fill(
                  child: Image.memory(
                      base64Decode(asset.thumbnail!.base64EncodedThumbnail!),
                      fit: BoxFit.cover),
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
            ),
          ),
          // Display a Circle icon if the asset is not selected
          if (widget.gridController.value.amount > 0 &&
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
          if (widget.selected)
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
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Future.value(asset.thumbnail!.base64EncodedThumbnail),
      builder: (context, snapshot) {
        final base64EncodedThumbnail = snapshot.data;
        // If we have no data, display a spinner
        if (base64EncodedThumbnail == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return _body(asset);
      },
    );
  }
}
