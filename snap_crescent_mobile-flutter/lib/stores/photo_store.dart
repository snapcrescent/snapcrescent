import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/stores/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class PhotoStore extends AssetStore {
  
  @override
  getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.assetType = ASSET_TYPE.PHOTO.index;
    return assetSearchCriteria;

  }
  
}
