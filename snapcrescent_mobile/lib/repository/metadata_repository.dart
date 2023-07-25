import 'package:snapcrescent_mobile/models/metadata/metadata.dart';
import 'package:snapcrescent_mobile/repository/base_repository.dart';
import 'package:snapcrescent_mobile/repository/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MetadataRepository extends BaseRepository {
  static const _tableName = 'METADATA';

  static final MetadataRepository _singleton = MetadataRepository._internal();

  factory MetadataRepository() {
    return _singleton;
  }

  MetadataRepository._internal() : super(_tableName);

  Future<Metadata?> findByLocalAssetId(String localAssetId) async {
    Database database = await DatabaseHelper().database;
    final result = await database.rawQuery(
        '''SELECT * from $tableName where LOCAL_ASSET_ID = ? ''',
        [localAssetId]);

    Metadata? metadata;

    if (result.length == 1) {
      metadata = Metadata.fromMap(result.single);
    }

    return metadata;
  }

  Future<List<Metadata>?> findByName(String name) async {
    Database database = await DatabaseHelper().database;
    final result = await database
        .rawQuery('''SELECT * from $tableName where NAME = ? ''', [name]);

    return result.map((e) => Metadata.fromMap(e)).toList();
  }

  Future<Metadata?> findByNameAndSize(String name, int size) async {
    Database database = await DatabaseHelper().database;
    final result = await database.rawQuery(
        '''SELECT * from $tableName where NAME = ? AND SIZE = ?''',
        [name, size]);

    Metadata? metadata;

    if (result.length == 1) {
      metadata = Metadata.fromMap(result.single);
    }

    return metadata;
  }

  Future<int> countByLocalAssetIdNotNull() async {
    Database database = await DatabaseHelper().database;
    final result = await database.rawQuery(
      '''SELECT COUNT($_tableName.ID) from $tableName where LOCAL_ASSET_ID IS NOT NULL''',
    );
    return Sqflite.firstIntValue(result)!;
  }

  Future<int?> sizeByLocalAssetIdNotNull() async {
    Database database = await DatabaseHelper().database;
    final result = await database.rawQuery(
      '''SELECT SUM($_tableName.SIZE) from $tableName where LOCAL_ASSET_ID IS NOT NULL''',
    );
    return Sqflite.firstIntValue(result);
  }

  Future<List<Metadata>?> findByLocalAssetIdNotNull() async {
    Database database = await DatabaseHelper().database;
    final result = await database.rawQuery(
        '''SELECT * from $tableName where LOCAL_ASSET_ID IS NOT NULL''');
    return result.map((e) => Metadata.fromMap(e)).toList();
  }
}
