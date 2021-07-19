import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:snap_crescent/models/local_assets_grid_arguments.dart';
import 'package:snap_crescent/screens/app_drawer/app_drawer.dart';
import 'package:snap_crescent/screens/local/grid/local_assets_grid.dart';
import 'package:snap_crescent/screens/local/library/library_tile.dart';
import 'package:snap_crescent/stores/local_asset_store.dart';
import 'package:snap_crescent/stores/local_photo_store.dart';
import 'package:snap_crescent/stores/local_video_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class LocalLibraryScreen extends StatelessWidget {
  static const routeName = '/local_library';

  final ViewType type;

  LocalLibraryScreen(this.type);

  @override
  Widget build(BuildContext context) {
    return _LocalLibraryView(type);
  }
}

class _LocalLibraryView extends StatefulWidget {

   final ViewType type;

   _LocalLibraryView(this.type);

  @override
  _LocalLibraryViewState createState() => _LocalLibraryViewState();
}

class _LocalLibraryViewState extends State<_LocalLibraryView> {
  
  _onFolderTap(BuildContext context, String folderName) {
    
    LocalAssetsGridArguments arguments = new LocalAssetsGridArguments(type: widget.type, folderName: folderName);

    Navigator.pushNamed(
      context,
      LocalAssetsGridScreen.routeName,
      arguments: arguments,
    );
  }

  _gridView(Orientation orientation, LocalAssetStore localAssetStore) {
       final filteredKeys = localAssetStore.groupedAssets.keys.where((key) => localAssetStore.groupedAssets[key]!.length > 0).toList();
       return GridView.count(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        crossAxisCount:
                            orientation == Orientation.portrait ? 3 : 6,
                        childAspectRatio: orientation ==  Orientation.portrait ? (2 / 2.7) : (2 / 3),
                        children: filteredKeys
                            .map((assetFolder) => GestureDetector(
                                child: LibraryTile(widget.type,assetFolder),
                                onTap: () => _onFolderTap(context,assetFolder)))
                            .toList(),
                      );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LocalAssetStore localAssetStore = widget.type == ViewType.PHOTO ? Provider.of<LocalPhotoStore>(context) : Provider.of<LocalVideoStore>(context);
   
    _body() {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.type == ViewType.PHOTO ? "Photo" : "Video" + ' Library'),
          backgroundColor: Colors.black,
        ),
        drawer: AppDrawer(),
        body: Row(
          children: <Widget>[
            Expanded(
                child: Observer(
                    builder: (context) => localAssetStore.groupedAssets.isNotEmpty
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
}
