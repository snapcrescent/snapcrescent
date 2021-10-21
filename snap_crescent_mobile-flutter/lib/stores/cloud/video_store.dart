
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/stores/cloud/asset_store.dart';
import 'package:snap_crescent/utils/constants.dart';

class VideoStore extends AssetStore {
  
  @override
  getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.assetType = ASSET_TYPE.VIDEO.index;
    return assetSearchCriteria;

  }
  
}
