import 'package:snapcrescent_mobile/models/asset.dart';
import 'package:snapcrescent_mobile/models/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/repository/base_repository.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:snapcrescent_mobile/repository/query_bean.dart';
import 'package:sqflite/sqflite.dart';

class AssetRepository extends BaseRepository{

  static final _tableName = 'ASSET'; 

  AssetRepository._privateConstructor():super(_tableName);
  static final AssetRepository instance = AssetRepository._privateConstructor();

  Future<int> countOnLocal(AssetSearchCriteria assetSearchCriteria) async {
    Database database = await DatabaseHelper.instance.database;
    QueryBean queryBean = getSearchQuery(assetSearchCriteria, true);
    final result = await database.rawQuery(queryBean.query,queryBean.arguments).then((value) => value);
    return Sqflite.firstIntValue(result)!;
  }

   Future<List<Asset>> searchOnLocal(AssetSearchCriteria assetSearchCriteria) async {
    Database database = await DatabaseHelper.instance.database;
    QueryBean queryBean = getSearchQuery(assetSearchCriteria, false);
    final result = await database.rawQuery(queryBean.query,queryBean.arguments);
    return result.map((e) => Asset.fromMap(e)).toList();
  }

  QueryBean getSearchQuery(AssetSearchCriteria assetSearchCriteria, bool isCountQuery) {
    
    List<Object?>? arguments = [];
    StringBuffer buffer = new StringBuffer();

    if(isCountQuery) {
        buffer.write(" SELECT COUNT($_tableName.ID) from ");
    } else {
        buffer.write(" SELECT $_tableName.* from ");
    }
    
    buffer.write(tableName);
    buffer.write(" JOIN METADATA on METADATA.ID = $_tableName.METADATA_ID ");
    buffer.write(" WHERE 1=1 ");

    if(assetSearchCriteria.assetType != null) {
      buffer.write(" AND $_tableName.ASSET_TYPE = ? ");
      arguments.add(assetSearchCriteria.assetType);
    }

    
    if(assetSearchCriteria.active != null) {
      buffer.write(" AND $_tableName.ACTIVE = ? ");
      arguments.add((assetSearchCriteria.active! ? 1 : 0));
    }


    buffer.write(" ORDER BY METADATA.CREATION_DATE_TIME DESC ");

    if(!isCountQuery) {
        buffer.write(getPagingQuery(assetSearchCriteria));
    }
    

    return new QueryBean(buffer.toString(), arguments);
  }

}