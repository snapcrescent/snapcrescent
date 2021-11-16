import 'package:snap_crescent/repository/base_repository.dart';

class SyncInfoRepository extends BaseRepository{

  static final _tableName = 'SYNC_INFO'; 

  SyncInfoRepository._privateConstructor():super(_tableName);
  static final SyncInfoRepository instance = SyncInfoRepository._privateConstructor();
 
}