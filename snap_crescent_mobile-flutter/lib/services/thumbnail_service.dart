import 'package:snap_crescent/models/thumbnail.dart';
import 'package:snap_crescent/repository/thumbnail_repository.dart';

class ThumbnailService {

  ThumbnailService._privateConstructor():super();
  static final ThumbnailService instance = ThumbnailService._privateConstructor();
  
  Future<int> saveOnLocal(Thumbnail entity) async {
    return ThumbnailRepository.instance.save(entity);
  }

  Future<Thumbnail> findByIdOnLocal(int id) async {
    final result = await  ThumbnailRepository.instance.findById(id);
    return Thumbnail.fromMap(result);
  }

}
