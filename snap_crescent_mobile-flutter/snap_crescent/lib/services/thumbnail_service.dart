import 'package:snap_crescent/models/thumbnail.dart';
import 'package:snap_crescent/resository/thumbnail_resository.dart';

class ThumbnailService {
  
  Future<int> saveOnLocal(Thumbnail entity) async {
    return ThumbnailResository.instance.save(entity);
  }

  Future<Thumbnail> findByIdOnLocal(int id) async {
    final result = await  ThumbnailResository.instance.findById(id);
    return Thumbnail.fromMap(result);
  }

}
