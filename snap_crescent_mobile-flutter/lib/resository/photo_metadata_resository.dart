import 'package:snap_crescent/resository/base_repository.dart';

class PhotoMetadataResository extends BaseResository {

  static final _tableName = 'PHOTO_METADATA'; 

  PhotoMetadataResository._privateConstructor():super(_tableName);
  static final PhotoMetadataResository instance = PhotoMetadataResository._privateConstructor();


}