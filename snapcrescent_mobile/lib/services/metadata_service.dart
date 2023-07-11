import 'package:snapcrescent_mobile/models/metadata.dart';
import 'package:snapcrescent_mobile/repository/metadata_repository.dart';

class MetadataService {

  MetadataService._privateConstructor():super();
  static final MetadataService instance = MetadataService._privateConstructor();
  
  Future<int> saveOnLocal(Metadata entity) async {
    return MetadataRepository.instance.save(entity);
  }

  Future<Metadata> findByIdOnLocal(int id) async {
    final result = await  MetadataRepository.instance.findById(id);
    return Metadata.fromMap(result);
  }

  Future<Metadata?> findByNameAndSize(String name, int size) async {
    return await MetadataRepository.instance.findByNameAndSize(name, size);
  }

}
