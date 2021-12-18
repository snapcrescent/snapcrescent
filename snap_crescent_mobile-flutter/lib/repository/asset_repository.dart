import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/repository/base_repository.dart';
import 'package:snap_crescent/repository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AssetRepository extends BaseRepository{

  static final _tableName = 'ASSET'; 

  AssetRepository._privateConstructor():super(_tableName);
  static final AssetRepository instance = AssetRepository._privateConstructor();

   Future<List<Asset>> searchOnLocal(AssetSearchCriteria assetSearchCriteria) async {
    Database database = await DatabaseHelper.instance.database;

    List<Object?>? arguments = [];

    StringBuffer buffer = new StringBuffer();

    buffer.write(" SELECT $_tableName.* from ");
    buffer.write(tableName);
    buffer.write(" JOIN METADATA on METADATA.ID = $_tableName.METADATA_ID ");
    buffer.write(" WHERE 1=1 ");

    if(assetSearchCriteria.assetType != null) {
      buffer.write(" AND $_tableName.ASSET_TYPE = ? ");
      arguments.add(assetSearchCriteria.assetType);
    }


    buffer.write(" ORDER BY METADATA.CREATION_DATETIME DESC ");
    buffer.write(getPagingQuery(assetSearchCriteria));
    

    final result = await database.rawQuery(buffer.toString(),arguments);
    
    return result.map((e) => Asset.fromMap(e)).toList();
  }

}