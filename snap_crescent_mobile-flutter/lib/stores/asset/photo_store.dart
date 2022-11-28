import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart' as AppConstants;

class PhotoStore extends AssetStore {
  
  @override
  getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.assetType = AppConstants.AppAssetType.PHOTO.id;
    assetSearchCriteria.resultPerPage = 1000;
    return assetSearchCriteria;
  }

  @override
  getFilteredAssets(List<AssetEntity> allAssets) {
    return allAssets.where((asset) => asset.type == AssetType.image);
  }

  
}
