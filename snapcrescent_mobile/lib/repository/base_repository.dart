import 'package:snapcrescent_mobile/models/common/base_model.dart';
import 'package:snapcrescent_mobile/models/common/base_search_criteria.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class BaseRepository {

  String tableName;

  BaseRepository(this.tableName);

  Future<int> saveOrUpdate(BaseUiBean entity) async {
      if(entity.id != null && await existsById(entity.id!)) {
        return await DatabaseHelper().update(tableName,entity.toMap());  
      } else {
        return await DatabaseHelper().save(tableName,entity.toMap());  
      }
      
  }

  Future<List<Map<String,dynamic>>> findAll() async {
      return await DatabaseHelper().findAll(tableName);
  }

  Future<Map<String,dynamic>?> findById(int id) async {
      final result = await DatabaseHelper().findById(tableName,id);
      
      if(result.isNotEmpty) {
        return result.elementAt(0);
      } else{
        return null;
      }
  }

  Future<bool> existsById(int id) async {
      Database database = await DatabaseHelper().database;
      final result = await database.rawQuery('''SELECT COUNT(*) from $tableName where ID = $id''').then((value) => value);
      return (Sqflite.firstIntValue(result)! > 0) ? true : false;
  }

  Future<int> deleteAll() async {
      return await DatabaseHelper().deleteAll(tableName);
  }

  Future<int> delete(int id) async {
      return await DatabaseHelper().delete(tableName,id);
  }

  String getPagingQuery(BaseSearchCriteria searchCriteria) {
    int resultPerPage = searchCriteria.resultPerPage!;
    int pageNumber = searchCriteria.pageNumber!;
    int offset = (pageNumber * resultPerPage);
    
    return ''' LIMIT $resultPerPage OFFSET $offset''';
  }
}