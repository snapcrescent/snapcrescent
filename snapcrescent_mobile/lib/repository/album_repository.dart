import 'package:snapcrescent_mobile/models/album/album.dart';
import 'package:snapcrescent_mobile/models/album/album_search_criteria.dart';
import 'package:snapcrescent_mobile/repository/base_repository.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:snapcrescent_mobile/repository/query_bean.dart';
import 'package:sqflite/sqflite.dart';

class AlbumRepository extends BaseRepository{

  static final _tableName = 'ALBUM'; 

  AlbumRepository._privateConstructor():super(_tableName);
  static final AlbumRepository instance = AlbumRepository._privateConstructor();

  Future<int> countOnLocal(AlbumSearchCriteria albumSearchCriteria) async {
    Database database = await DatabaseHelper.instance.database;
    QueryBean queryBean = getSearchQuery(albumSearchCriteria, true);
    final result = await database.rawQuery(queryBean.query,queryBean.arguments).then((value) => value);
    return Sqflite.firstIntValue(result)!;
  }

   Future<List<Album>> searchOnLocal(AlbumSearchCriteria albumSearchCriteria) async {
    Database database = await DatabaseHelper.instance.database;
    QueryBean queryBean = getSearchQuery(albumSearchCriteria, false);
    final result = await database.rawQuery(queryBean.query,queryBean.arguments);
    return result.map((e) => Album.fromMap(e)).toList();
  }

  QueryBean getSearchQuery(AlbumSearchCriteria albumSearchCriteria, bool isCountQuery) {
    
    List<Object?>? arguments = [];
    StringBuffer buffer = new StringBuffer();

    if(isCountQuery) {
        buffer.write(" SELECT COUNT($_tableName.ID) from ");
    } else {
        buffer.write(" SELECT $_tableName.* from ");
    }
    
    buffer.write(tableName);
    buffer.write(" WHERE 1=1 ");

   

    if(!isCountQuery) {
        buffer.write(getPagingQuery(albumSearchCriteria));
    }
    

    return new QueryBean(buffer.toString(), arguments);
  }

  

}