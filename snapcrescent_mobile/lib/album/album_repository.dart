import 'package:snapcrescent_mobile/album/album.dart';
import 'package:snapcrescent_mobile/album/album_search_criteria.dart';
import 'package:snapcrescent_mobile/common/repository/base_repository.dart';
import 'package:snapcrescent_mobile/common/repository/database_helper.dart';
import 'package:snapcrescent_mobile/common/repository/query_bean.dart';

class AlbumRepository extends BaseRepository{

  static const _tableName = 'ALBUM'; 

  static final AlbumRepository _singleton = AlbumRepository._internal();

  factory AlbumRepository() {
    return _singleton;
  }

  AlbumRepository._internal():super(_tableName);

  Future<int> countOnLocal(AlbumSearchCriteria albumSearchCriteria) async {
    QueryBean queryBean = getSearchQuery(albumSearchCriteria, true);
    final results = await DatabaseHelper().get(queryBean.query,queryBean.arguments);
    return results != null ? results.columnAt(0) : 0;
  }

   Future<List<Album>> searchOnLocal(AlbumSearchCriteria albumSearchCriteria) async {
    QueryBean queryBean = getSearchQuery(albumSearchCriteria, false);
    final results = await DatabaseHelper().getAll(queryBean.query,queryBean.arguments);
    return results.map((e) => Album.fromMap(e)).toList();
  }

  QueryBean getSearchQuery(AlbumSearchCriteria albumSearchCriteria, bool isCountQuery) {
    
    List<Object?>? arguments = [];
    StringBuffer buffer = StringBuffer();

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
    

    return QueryBean(buffer.toString(), arguments);
  }

  

}