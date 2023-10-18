import 'package:snapcrescent_mobile/common/model/base_model.dart';
import 'package:snapcrescent_mobile/common/model/base_search_criteria.dart';
import 'package:snapcrescent_mobile/common/repository/database_helper.dart';
import 'package:sqlite_async/sqlite3.dart';

class BaseRepository {

  String tableName;

  BaseRepository(this.tableName);

  Future<void> saveOrUpdate(BaseUiBean entity) async {
      if(entity.id != null && await existsById(entity.id!)) {
        await DatabaseHelper().update(tableName,entity.toMap(), 'ID = ?',entity.id!.toString());  
      } else {
        await DatabaseHelper().save(tableName,entity.toMap());  
      }
      
  }

    Future<void> saveOrUpdateAll(List<BaseUiBean> entities) async {

      List<BaseUiBean> saveList = [];
      List<BaseUiBean> updateList = [];

      for (BaseUiBean entity in entities) {
        if(entity.id != null && await existsById(entity.id!)) {
          updateList.add(entity);
        } else {
          saveList.add(entity);
        }
      }
 
      for (int index = 0; index < updateList.length; index++) {
          BaseUiBean entity = updateList.elementAt(index);
          Map<String, dynamic> row = entity.toMap();
          await DatabaseHelper().update(tableName,row, 'ID = ?',entity.id!.toString());  
      }

      await DatabaseHelper().saveAll(tableName,saveList.map((e) => e.toMap()).toList());  
  }

  Future<List<Map<String,dynamic>>> findAll() async {
      return await DatabaseHelper().findAll(tableName);
  }

  Future<List<int>> findAllIds() async {
    final List<Row> rows = await DatabaseHelper().getAll('SELECT ID from $tableName',[]);
    return rows.map((row) => int.parse(row.columnAt(0).toString())).toList();
  }

  Future<int> findMaxId() async {
    Row? row = await DatabaseHelper().get('SELECT MAX(ID) from $tableName', []);
    
    int maxId = 0;

    if(row != null && row.columnAt(0) != null) {
      maxId = row.columnAt(0);
    }
    return maxId;
  }

  Future<Map<String,dynamic>?> findById(int id) async {
      return await DatabaseHelper().findById(tableName,id);
  }

  Future<bool> existsById(int id) async {
      Row? row = await DatabaseHelper().get('''SELECT COUNT(*) from $tableName where ID = ?''',[id]);
      return (row != null && row.columnAt(0) > 0) ? true : false;
  }

  Future<void> deleteAll() async {
      await DatabaseHelper().deleteAll(tableName);
  }

  Future<void> delete(int id) async {
      await DatabaseHelper().delete(tableName,id);
  }

  String getPagingQuery(BaseSearchCriteria searchCriteria) {
    int resultPerPage = searchCriteria.resultPerPage!;
    int pageNumber = searchCriteria.pageNumber!;
    int offset = (pageNumber * resultPerPage);
    
    return ''' LIMIT $resultPerPage OFFSET $offset''';
  }
}