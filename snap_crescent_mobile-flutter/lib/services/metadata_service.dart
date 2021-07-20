import 'package:snap_crescent/models/metadata.dart';
import 'package:snap_crescent/resository/metadata_resository.dart';

class MetadataService {
  
  Future<int> saveOnLocal(Metadata entity) async {
    return MetadataResository.instance.save(entity);
  }

  Future<Metadata> findByIdOnLocal(int id) async {
    final result = await  MetadataResository.instance.findById(id);
    return Metadata.fromMap(result);
  }

}
