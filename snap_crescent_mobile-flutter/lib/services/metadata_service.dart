import 'package:snap_crescent/models/metadata.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';

class MetadataService {
  
  Future<int> saveOnLocal(Metadata entity) async {
    return MetadataRepository.instance.save(entity);
  }

  Future<Metadata> findByIdOnLocal(int id) async {
    final result = await  MetadataRepository.instance.findById(id);
    return Metadata.fromMap(result);
  }

}
