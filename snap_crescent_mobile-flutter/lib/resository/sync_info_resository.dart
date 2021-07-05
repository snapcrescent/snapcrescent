import 'package:snap_crescent/resository/base_repository.dart';

class SyncInfoResository extends BaseResository{

  static final _tableName = 'SYNC_INFO'; 

  SyncInfoResository._privateConstructor():super(_tableName);
  static final SyncInfoResository instance = SyncInfoResository._privateConstructor();
 
}