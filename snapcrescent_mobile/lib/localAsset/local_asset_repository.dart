import 'package:snapcrescent_mobile/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/common/repository/base_repository.dart';
import 'package:snapcrescent_mobile/common/repository/database_helper.dart';
import 'package:snapcrescent_mobile/common/repository/query_bean.dart';
import 'package:snapcrescent_mobile/localAsset/local_asset.dart';

class LocalAssetRepository extends BaseRepository {
  static const _tableName = LocalAsset.tableName;

  static final LocalAssetRepository _singleton = LocalAssetRepository._internal();

  factory LocalAssetRepository() {
    return _singleton;
  }

  LocalAssetRepository._internal() : super(LocalAsset.tableName);

  Future<LocalAsset?> findByAssetId(String id) async {
    final result = await DatabaseHelper().get('''SELECT * from $tableName where LOCAL_ASSET_ID = ?''', [id]);

    LocalAsset? localAsset;

    if (result != null) {
      localAsset = LocalAsset.fromMap(result);
    }

    return localAsset;
  }

  Future<DateTime?> getMaxAssetDateByAlbum(String albumId) async {
    final result = await DatabaseHelper().get('''SELECT * from $tableName where LOCAL_ALBUM_ID = ?''', [albumId]);

    DateTime? maxAssetDate;

    if (result != null) {
      LocalAsset localAsset = LocalAsset.fromMap(result);
      maxAssetDate = localAsset.creationDateTime;
    }

    return maxAssetDate;
  }

  Future<int> count(AssetSearchCriteria assetSearchCriteria) async {
    QueryBean queryBean = getSearchQuery(assetSearchCriteria, true);
    final results = await DatabaseHelper().get(queryBean.query, queryBean.arguments);
    return results != null ? results.columnAt(0) : 0;
  }

  Future<List<LocalAsset>> search(AssetSearchCriteria assetSearchCriteria) async {
    QueryBean queryBean = getSearchQuery(assetSearchCriteria, false);
    final results = await DatabaseHelper().getAll(queryBean.query, queryBean.arguments);
    return results.map((row) => LocalAsset.fromMap(row)).toList();
  }

  QueryBean getSearchQuery(AssetSearchCriteria assetSearchCriteria, bool isCountQuery) {
    List<Object?>? arguments = [];
    StringBuffer buffer = StringBuffer();

    if (isCountQuery) {
      buffer.write(" SELECT COUNT($_tableName.ID) from ");
    } else {
      buffer.write(" SELECT $_tableName.* from ");
    }

    buffer.write(tableName);
    buffer.write(" WHERE 1=1 ");

    if (assetSearchCriteria.albumIds != null && assetSearchCriteria.albumIds!.isNotEmpty) {
      buffer.write(" AND $_tableName.LOCAL_ALBUM_ID IN (?) ");
      arguments.add(assetSearchCriteria.albumIds!.join(','));
    }

    buffer.write(" ORDER BY $_tableName.CREATION_DATE_TIME DESC ");

    if (!isCountQuery) {
      buffer.write(getPagingQuery(assetSearchCriteria));
    }

    return QueryBean(buffer.toString(), arguments);
  }
}
