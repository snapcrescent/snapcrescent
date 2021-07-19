import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';

part 'local_asset_store.g.dart';

abstract class LocalAssetStore = _LocalAssetStore with _$LocalAssetStore;

abstract class _LocalAssetStore with Store {
  
  _LocalAssetStore() {
    getAssets();
  }

  List<AssetEntity> assetList = new List.empty();

  @observable
  Map<String, List<AssetEntity>> groupedAssets = new Map();

  @action
  Future<void> getAssets() async {
    assetList = [];
    groupedAssets.clear();

    final albums = await PhotoManager.getAssetPathList();
    albums.sort((AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

    albums.forEach((album) {
      if(album.name != 'Recent') {
        groupedAssets.putIfAbsent(album.name, () => []);
        _updateAssetList(album);
      }
    });
  }

  AssetEntity getAssetAtIndex(int assetIndex) {
    return assetList[assetIndex];
  }

  _updateAssetList(AssetPathEntity? album) async {
    if (album != null) {
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );

      final assets = getFilteredAssets(allAssets);

      if (assets.length > 0) {
        assetList.addAll(assets);
        groupedAssets[album.name] = List.from(assets);
      }
    }
  }

  Iterable<AssetEntity> getFilteredAssets(List<AssetEntity> allAssets);

}
