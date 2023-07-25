import 'package:snapcrescent_mobile/models/metadata/metadata.dart';
import 'package:snapcrescent_mobile/repository/metadata_repository.dart';

class MetadataService {

  static final MetadataService _singleton = MetadataService._internal();

  factory MetadataService() {
    return _singleton;
  }

  MetadataService._internal();
  
  Future<int> saveOrUpdate(Metadata entity) async {
    return MetadataRepository().saveOrUpdate(entity);
  }

  Future<Metadata?> findById(int id) async {
    final result = await  MetadataRepository().findById(id);

    if(result != null) {
      return Metadata.fromMap(result);
    } else {
      return null;
    }
    
  }

  Future<Metadata?> findByLocalAssetId(String localAssetId) async {
    return await MetadataRepository().findByLocalAssetId(localAssetId);
  }

  Future<List<Metadata>?> findByName(String name) async {
    return await MetadataRepository().findByName(name);
  }

  Future<Metadata?> findByNameAndSize(String name, int size) async {
    return await MetadataRepository().findByNameAndSize(name, size);
  }

  Future<int> countByLocalAssetIdNotNull() async {
    return MetadataRepository().countByLocalAssetIdNotNull();
  }

  Future<int> sizeByLocalAssetIdNotNull() async {
    int? sizeInBytes = await MetadataRepository().sizeByLocalAssetIdNotNull();

    if(sizeInBytes != null) {
      return sizeInBytes;
    } else {
      return 0;
    }
  }

  Future<List<Metadata>?> findByLocalAssetIdNotNull() async {
    return MetadataRepository().findByLocalAssetIdNotNull();
  }

  

}
