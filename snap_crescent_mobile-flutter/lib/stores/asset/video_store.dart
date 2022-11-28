
import 'package:photo_manager/photo_manager.dart' as PhotoManager;
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/stores/asset/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart' as AppConstants;

class VideoStore extends AssetStore {
  
  @override
  getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.assetType = AppConstants.AppAssetType.VIDEO.id;
    assetSearchCriteria.resultPerPage = 500;
    return assetSearchCriteria;

  }

  @override
  getFilteredAssets(List<PhotoManager.AssetEntity> allAssets) {
    return allAssets.where((asset) => asset.type == PhotoManager.AssetType.video);
  }
  
}
