import 'package:snapcrescent_mobile/repository/base_repository.dart';

class ThumbnailRepository extends BaseRepository{

  static const _tableName = 'THUMBNAIL'; 

  static final ThumbnailRepository _singleton = ThumbnailRepository._internal();

  factory ThumbnailRepository() {
    return _singleton;
  }

  ThumbnailRepository._internal():super(_tableName);
  
}