import 'package:snapcrescent_mobile/models/metadata.dart';
import 'package:snapcrescent_mobile/repository/base_repository.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MetadataRepository extends BaseRepository {

  static final _tableName = 'METADATA'; 

  MetadataRepository._privateConstructor():super(_tableName);
  static final MetadataRepository instance = MetadataRepository._privateConstructor();

  Future<Metadata?> findByNameAndSize(String name, int size) async {
    Database database = await DatabaseHelper.instance.database;
    final result = await database.rawQuery('''SELECT * from $tableName where NAME = ? AND SIZE = ?''',[name, size]);
   
    Metadata? metadata;

    if (result.length == 1) {
      metadata = Metadata.fromMap(result.single);
    }

    return metadata;
  }


}