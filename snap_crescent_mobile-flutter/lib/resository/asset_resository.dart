import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/resository/base_repository.dart';
import 'package:snap_crescent/resository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AssetResository extends BaseResository{

  static final _tableName = 'ASSET'; 

  AssetResository._privateConstructor():super(_tableName);
  static final AssetResository instance = AssetResository._privateConstructor();

   Future<List<Asset>> searchOnLocal(AssetSearchCriteria assetSearchCriteria) async {
    Database database = await DatabaseHelper.instance.database;

    List<Object?>? arguments = [];

    StringBuffer buffer = new StringBuffer();

    buffer.write(" SELECT * from ");
    buffer.write(tableName);
    buffer.write(" JOIN METADATA on METADATA.ID = $_tableName.METADATA_ID ");
    buffer.write(" WHERE 1=1 ");

    if(assetSearchCriteria.assetType != null) {
      buffer.write(" AND $_tableName.ASSET_TYPE = ? ");
      arguments.add(assetSearchCriteria.assetType);
    }

    buffer.write(" ORDER BY METADATA.CREATION_DATETIME DESC ");

    final result = await database.rawQuery(buffer.toString(),arguments);
    
    return result.map((e) => Asset.fromMap(e)).toList();
  }

}