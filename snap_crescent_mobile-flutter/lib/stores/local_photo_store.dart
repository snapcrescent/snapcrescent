import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/stores/local_asset_store.dart';

class LocalPhotoStore extends LocalAssetStore {
  
  @override
  getFilteredAssets(List<AssetEntity> allAssets) {
    return allAssets.where((asset) => asset.type == AssetType.image);
  }

}
