import 'package:snap_crescent/models/photo_metadata.dart';
import 'package:snap_crescent/resository/photo_metadata_resository.dart';

class PhotoMetadataService {
  
  Future<int> saveOnLocal(PhotoMetadata entity) async {
    return PhotoMetadataResository.instance.save(entity);
  }

  Future<PhotoMetadata> findByIdOnLocal(int id) async {
    final result = await  PhotoMetadataResository.instance.findById(id);
    return PhotoMetadata.fromMap(result);
  }

}
