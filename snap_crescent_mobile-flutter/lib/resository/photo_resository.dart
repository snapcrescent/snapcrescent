import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/resository/base_repository.dart';
import 'package:snap_crescent/resository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class PhotoResository extends BaseResository{

  static final _tableName = 'PHOTO'; 

  PhotoResository._privateConstructor():super(_tableName);
  static final PhotoResository instance = PhotoResository._privateConstructor();

   Future<List<Photo>> searchOnLocal() async {
    Database database = await DatabaseHelper.instance.database;
    final result = await database.rawQuery(
        '''SELECT * from $tableName JOIN PHOTO_METADATA on PHOTO_METADATA.ID = $_tableName.PHOTO_METADATA_ID ORDER BY PHOTO_METADATA.CREATION_DATETIME DESC''');
    
    return result.map((e) => Photo.fromMap(e)).toList();
  }

}