import 'package:snapcrescent_mobile/metadata/metadata.dart';
import 'package:snapcrescent_mobile/common/repository/base_repository.dart';
import 'package:snapcrescent_mobile/common/repository/database_helper.dart';

class MetadataRepository extends BaseRepository {
  static const _tableName = 'METADATA';

  static final MetadataRepository _singleton = MetadataRepository._internal();

  factory MetadataRepository() {
    return _singleton;
  }

  MetadataRepository._internal() : super(_tableName);

  Future<Metadata?> findByLocalAssetId(String localAssetId) async {
    final result = await DatabaseHelper().get(
        '''SELECT * from $tableName where LOCAL_ASSET_ID = ? ''',
        [localAssetId]);

    Metadata? metadata;

    if (result != null) {
      metadata = Metadata.fromMap(result);
    }

    return metadata;
  }

  Future<bool> existByLocalAssetId(String localAssetId) async {
    final result = await DatabaseHelper().get(
        '''SELECT COUNT(*) from $tableName where LOCAL_ASSET_ID = ? ''',
        [localAssetId]);

    int count = result != null ? result.columnAt(0) : 0;
    return count > 0 ? true : false;
  }

  Future<bool> existByName(String name) async {
    final result = await DatabaseHelper().get('''SELECT COUNT(*) from $tableName where NAME = ? ''', [name]);

    int count = result != null ? result.columnAt(0) : 0;
    return count > 0 ? true : false;
  }

  

  Future<Metadata?> findByNameAndSize(String name, int size) async {
    final result = await DatabaseHelper().get(
        '''SELECT * from $tableName where NAME = ? AND SIZE = ?''',
        [name, size]);

    Metadata? metadata;

    if (result != null) {
      metadata = Metadata.fromMap(result);
    }

    return metadata;
  }

  Future<int> countByLocalAssetIdNotNull() async {
    final result = await DatabaseHelper().get(
      '''SELECT COUNT($_tableName.ID) from $tableName where LOCAL_ASSET_ID IS NOT NULL''',[]
    );
    return result != null ? result.columnAt(0) : 0;
  }

  Future<int?> sizeByLocalAssetIdNotNull() async {
    final result = await DatabaseHelper().get(
      '''SELECT SUM($_tableName.SIZE) from $tableName where LOCAL_ASSET_ID IS NOT NULL''',[]
    );
    return result != null ? result.columnAt(0) : 0;
  }

  Future<List<Metadata>?> findByLocalAssetIdNotNull() async {
    final result = await DatabaseHelper().getAll(
        '''SELECT * from $tableName where LOCAL_ASSET_ID IS NOT NULL''',[]);
    return result.map((e) => Metadata.fromMap(e)).toList();
  }
}
