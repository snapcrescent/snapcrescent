
import 'package:snapcrescent_mobile/common/repository/base_repository.dart';
import 'package:snapcrescent_mobile/common/repository/database_helper.dart';
import 'package:snapcrescent_mobile/localAsset/local_asset.dart';

class LocalAssetRepository extends BaseRepository {
  

  static final LocalAssetRepository _singleton = LocalAssetRepository._internal();

  factory LocalAssetRepository() {
    return _singleton;
  }

  LocalAssetRepository._internal() : super(LocalAsset.tableName);

  Future<DateTime?> getMaxAssetDateByAlbum(String albumId) async {
    final result = await DatabaseHelper().get(
        '''SELECT * from $tableName where LOCAL_ALBUM_ID = ?''',
        [albumId]);

    DateTime? maxAssetDate;

    if (result != null) {
      LocalAsset localAsset = LocalAsset.fromMap(result);
      maxAssetDate = localAsset.creationDateTime;
    }

    return maxAssetDate;
  }

}
