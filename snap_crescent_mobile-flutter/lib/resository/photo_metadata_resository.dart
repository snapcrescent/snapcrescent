import 'package:snap_crescent/resository/base_repository.dart';

class PhotoMetadataResository extends BaseResository {

  static final _tableName = 'PHOTO_METADATA'; 

  PhotoMetadataResository._privateConstructor():super(_tableName);
  static final PhotoMetadataResository instance = PhotoMetadataResository._privateConstructor();

  /*
  Future<int> save(PhotoMetadata entity) async {
      return await DatabaseHelper.instance.save(_tableName,entity.toMap());
  }

  Future<List<Map<String,dynamic>>> findAll() async {
      return await DatabaseHelper.instance.findAll(_tableName);
  }

  Future<int> update(PhotoMetadata entity) async {
      return await DatabaseHelper.instance.update(_tableName,entity.toMap());
  }

  Future<int> delete(int id) async {
      return await DatabaseHelper.instance.delete(_tableName,id);
  }
  */
}