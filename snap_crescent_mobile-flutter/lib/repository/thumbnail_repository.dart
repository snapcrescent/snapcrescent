import 'package:snap_crescent/repository/base_repository.dart';

class ThumbnailRepository extends BaseRepository{

  static final _tableName = 'THUMBNAIL'; 

  ThumbnailRepository._privateConstructor():super(_tableName);
  static final ThumbnailRepository instance = ThumbnailRepository._privateConstructor();
  
}