
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class VideoStore extends AssetStore {
  
  @override
  getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.assetType = ASSET_TYPE.VIDEO.index;
    return assetSearchCriteria;

  }

  @override
  getFilteredAssets(List<AssetEntity> allAssets) {
    return allAssets.where((asset) => asset.type == AssetType.video);
  }
  
}
