import 'package:snap_crescent/resository/base_repository.dart';

class ThumbnailResository extends BaseResository{

  static final _tableName = 'THUMBNAIL'; 

  ThumbnailResository._privateConstructor():super(_tableName);
  static final ThumbnailResository instance = ThumbnailResository._privateConstructor();
  
}