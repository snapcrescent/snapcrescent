import 'package:snap_crescent/resository/base_repository.dart';

class PhotoResository extends BaseResository{

  static final _tableName = 'PHOTO'; 

  PhotoResository._privateConstructor():super(_tableName);
  static final PhotoResository instance = PhotoResository._privateConstructor();

}