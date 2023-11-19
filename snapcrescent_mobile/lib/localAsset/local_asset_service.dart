
import 'package:snapcrescent_mobile/localAsset/local_asset.dart';
import 'package:snapcrescent_mobile/localAsset/local_asset_repository.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class LocalAssetService {

  static final LocalAssetService _singleton = LocalAssetService._internal();

  factory LocalAssetService() {
    return _singleton;
  }

  LocalAssetService._internal();
  
  Future<void> saveOrUpdate(LocalAsset entity) async {
    LocalAssetRepository().saveOrUpdate(entity);
  }

  Future<LocalAsset?> findById(int id) async {
    final result = await  LocalAssetRepository().findById(id);

    if(result != null) {
      return LocalAsset.fromMap(result);
    } else {
      return null;
    }
    
  }

  Future<DateTime> getMaxAssetDateByAlbum(String localAlbumId) async {
    DateTime? maxAssetDate = await LocalAssetRepository().getMaxAssetDateByAlbum(localAlbumId);

    //If no entry is found that means app don't know about any local assets of this album
    //Set min creation date for filter as 1 JAN 1970
    maxAssetDate??= Constants.lowDate;
    
     return maxAssetDate;
  }
}
