import 'package:snap_crescent/resository/base_repository.dart';
import 'package:snap_crescent/resository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class PhotoResository extends BaseResository{

  static final _tableName = 'PHOTO'; 

  PhotoResository._privateConstructor():super(_tableName);
  static final PhotoResository instance = PhotoResository._privateConstructor();

  Future<int> findNextById(int id) async {
      Database database = await DatabaseHelper.instance.database;
      final result = await database.rawQuery('''SELECT ID from $tableName where ID > $id LIMIT 1''');
      final int? nextId = result.isEmpty ? 0 : Sqflite.firstIntValue(result);
      return Future.value(nextId);
  }

  Future<int> findPreviousById(int id) async {
      Database database = await DatabaseHelper.instance.database;
      final result = await database.rawQuery('''SELECT ID from $tableName where ID < $id ORDER BY ID DESC LIMIT 1''');
      final int? previousId = result.isEmpty ? 0 : Sqflite.firstIntValue(result);
      return Future.value(previousId);
  }
  
}