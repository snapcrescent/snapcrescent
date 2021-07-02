import 'package:snap_crescent/models/base_model.dart';
import 'package:snap_crescent/resository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class BaseResository {

  String tableName;

  BaseResository(this.tableName);

  Future<int> save(BaseUiBean entity) async {
      return await DatabaseHelper.instance.save(tableName,entity.toMap());
  }

  Future<List<Map<String,dynamic>>> findAll() async {
      return await DatabaseHelper.instance.findAll(tableName);
  }

  Future<Map<String,dynamic>> findById(int id) async {
      final result = await DatabaseHelper.instance.findById(tableName,id);
      
      if(result.length > 0) {
        return result.elementAt(0);
      } else{
        return {};
      }
  }

  Future<bool> existsById(int id) async {
      Database database = await DatabaseHelper.instance.database;
      final result = await database.rawQuery('''SELECT COUNT(*) from $tableName where ID = $id''').then((value) => value);
      return (Sqflite.firstIntValue(result)! > 0) ? true : false;
  }

  Future<int> update(BaseUiBean entity) async {
      return await DatabaseHelper.instance.update(tableName,entity.toMap());
  }

  Future<int> deleteAll() async {
      return await DatabaseHelper.instance.deleteAll(tableName);
  }

  Future<int> delete(int id) async {
      return await DatabaseHelper.instance.delete(tableName,id);
  }
}