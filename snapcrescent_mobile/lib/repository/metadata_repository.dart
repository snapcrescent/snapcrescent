import 'package:snapcrescent_mobile/models/metadata.dart';
import 'package:snapcrescent_mobile/repository/base_repository.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MetadataRepository extends BaseRepository {

  static final _tableName = 'METADATA'; 

  MetadataRepository._privateConstructor():super(_tableName);
  static final MetadataRepository instance = MetadataRepository._privateConstructor();

  Future<Metadata> findByNameEndWith(String name) async {
    Database database = await DatabaseHelper.instance.database;
    final result = await database.rawQuery('''SELECT * from $tableName where NAME = ? ''',[name]);
   
    if (result.length == 1) {
      return Metadata.fromMap(result.single);
    } else {
      return Metadata.fromMap({});
    }
  }


}