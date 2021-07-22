import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/asset_detail_arguments.dart';
import 'package:snap_crescent/models/assets_grid_arguments.dart';
import 'package:snap_crescent/screens/local/grid/local_asset_thumbnail.dart';
import 'package:snap_crescent/screens/local/grid/local_asset_detail.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/stores/local_asset_store.dart';
import 'package:snap_crescent/stores/local_photo_store.dart';
import 'package:snap_crescent/stores/local_video_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class LocalAssetsGridScreen extends StatelessWidget {
  static const routeName = '/local_assets';

  final AssetGridArguments arguments;

  LocalAssetsGridScreen(this.arguments);

  @override
  Widget build(BuildContext context) {
    return _LocalPhotoGridView(arguments.type, arguments.folderName);
  }
}

class _LocalPhotoGridView extends StatefulWidget {
  final String folderName;
  final ASSET_TYPE type;

  _LocalPhotoGridView(this.type, this.folderName);

  @override
  _LocalPhotoGridViewState createState() => _LocalPhotoGridViewState();
}

class _LocalPhotoGridViewState extends State<_LocalPhotoGridView> {
  final controller = DragSelectGridViewController();
  bool fileUploadInProgress = false;

  _onAssetTap(BuildContext context, int assetIndex) {
    AssetDetailArguments arguments =
        new AssetDetailArguments(type: widget.type, assetIndex: assetIndex);

    Navigator.pushNamed(
      context,
      LocalAssetDetailScreen.routeName,
      arguments: arguments,
    );
  }

  _gridView(Orientation orientation, LocalAssetStore localAssetStore) {
    return new Container(
        color: Colors.black,
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext ctxt, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (localAssetStore.groupedAssets[widget.folderName]!.length >
                      0)
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(widget.folderName)),
                          DragSelectGridView(
                            gridController: controller,
                            padding: const EdgeInsets.all(8),
                            itemCount: localAssetStore
                                .groupedAssets[widget.folderName]!.length,
                            itemBuilder: (context, index, selected) {
                              final asset = localAssetStore
                                  .groupedAssets[widget.folderName]![index];
                              return LocalAssetThumbnail(index, asset,
                                  asset.thumbData, selected, controller, () {
                                _onAssetTap(context,
                                    localAssetStore.assetList.indexOf(asset));
                              });
                            },
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            physics:
                                NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                            shrinkWrap: true,
                          )
                        ])
                ],
              );
            }));
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocalAssetStore localAssetStore = widget.type == ASSET_TYPE.PHOTO
        ? Provider.of<LocalPhotoStore>(context)
        : Provider.of<LocalVideoStore>(context);

    _getAssetFiles(Set<int> assetIndexes) async {
      final List<AssetEntity> assets = assetIndexes
          .map((assetIndex) =>
              localAssetStore.groupedAssets[widget.folderName]![assetIndex])
          .toList();

      List<File> assetFiles = [];
      for (final AssetEntity asset in assets) {
        final File? assetFile = await asset.file;
        assetFiles.add(assetFile!);
      }
      return assetFiles;
    }

    _uploadAssetFiles() async {
      fileUploadInProgress = true;

      setState(() {});

      ToastService.showSuccess(
          (widget.type == ASSET_TYPE.PHOTO ? "Photo" : "Video") +
              " upload in Progress");
      final List<File> assetFiles =
          await _getAssetFiles(controller.value.selectedIndexes);

      try {
        if (widget.type == ASSET_TYPE.PHOTO) {
          await AssetService().save(ASSET_TYPE.PHOTO, assetFiles);
        } else {
          await AssetService().save(ASSET_TYPE.VIDEO, assetFiles);
        }

        ToastService.showSuccess(
            (widget.type == ASSET_TYPE.PHOTO ? "Photo" : "Video") +
                " uploaded successfully");
      } catch (e) {
        ToastService.showError("Unable to reach server");
        print(e);
      }

      fileUploadInProgress = false;

      setState(() {});
    }

    _shareAssetFiles() async {
      final List<File> assetFiles =
          await _getAssetFiles(controller.value.selectedIndexes);
      final List<String> filePaths =
          assetFiles.map((assetFile) => assetFile.path).toList();
      await Share.shareFiles(filePaths, mimeTypes: <String>['image/jpg']);
    }

    _getLeadingIcon() {
      if (controller.value.amount > 0) {
        return IconButton(
          onPressed: () {
            controller.clear();
          },
          icon: Icon(Icons.cancel),
        );
      }
    }

    _body() {
      return Scaffold(
        appBar: AppBar(
          leading: _getLeadingIcon(),
          title: Text(controller.value.amount == 0
              ? widget.folderName
              : (controller.value.amount.toString() + " Selected")),
          backgroundColor: Colors.black,
          actions: [
            if (controller.value.amount > 0)
              IconButton(
                  onPressed: () {
                    _uploadAssetFiles();
                  },
                  icon: Icon(Icons.upload, color: Colors.white)),
            if (controller.value.amount > 0)
              IconButton(
                  onPressed: () {
                    _shareAssetFiles();
                  },
                  icon: Icon(Icons.share, color: Colors.white))
          ],
        ),
        body: Row(
          children: <Widget>[
            Expanded(
                child: Observer(
                    builder: (context) => localAssetStore
                                .groupedAssets.isNotEmpty &&
                            fileUploadInProgress == false
                        ? OrientationBuilder(builder: (context, orientation) {
                            return _gridView(orientation, localAssetStore);
                          })
                        : Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              child: const CircularProgressIndicator(),
                            ),
                          )))
          ],
        ),
      );
    }

    return _body();
  }

  void scheduleRebuild() => setState(() {});
}
