import 'package:snap_crescent/resository/base_repository.dart';

class VideoResository extends BaseResository {

  static final _tableName = 'VIDEO'; 

  VideoResository._privateConstructor():super(_tableName);
  static final VideoResository instance = VideoResository._privateConstructor();


}