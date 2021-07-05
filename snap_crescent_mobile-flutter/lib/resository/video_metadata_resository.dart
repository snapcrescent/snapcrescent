import 'package:snap_crescent/resository/base_repository.dart';

class VideoMetadataResository extends BaseResository {

  static final _tableName = 'VIDEO_METADATA'; 

  VideoMetadataResository._privateConstructor():super(_tableName);
  static final VideoMetadataResository instance = VideoMetadataResository._privateConstructor();


}