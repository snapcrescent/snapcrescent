import 'dart:convert';

import 'package:http/http.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/sync_info_search_criteria.dart';
import 'package:snap_crescent/resository/photo_metadata_resository.dart';
import 'package:snap_crescent/resository/photo_resository.dart';
import 'package:snap_crescent/resository/sync_info_resository.dart';
import 'package:snap_crescent/resository/thumbnail_resository.dart';
import 'package:snap_crescent/resository/video_metadata_resository.dart';
import 'package:snap_crescent/resository/video_resository.dart';
import 'package:snap_crescent/services/base_service.dart';

class SyncInfoService extends BaseService {
  
  Future<BaseResponseBean<int, SyncInfo>> search(SyncInfoSearchCriteria searchCriteria) async {
    final baseUrl = await getServerUrl();
    final String queryString = getQueryString(searchCriteria.toMap());
    Response response = await get(Uri.parse('''$baseUrl/sync-info?$queryString'''));
    
    if (response.statusCode == 200) {
      return BaseResponseBean.fromJson(jsonDecode(response.body), SyncInfo.fromJsonModel);
    } else {
      throw "Unable to retrieve SyncInfo.";
    }
  }

  Future<int> saveOnLocal(SyncInfo entity) async {
    final syncInfoExistsById = await SyncInfoResository.instance.existsById(entity.id!);

    if(syncInfoExistsById == false) {
      return SyncInfoResository.instance.save(entity);
    } else {
      return Future.value(0);
    } 
  }

  Future<List<SyncInfo>> searchOnLocal() async {
    final localSyncInfosMap =  await SyncInfoResository.instance.findAll();
    return new List<SyncInfo>.from(localSyncInfosMap.map((syncInfoMap) => SyncInfo.fromMap(syncInfoMap)).toList());
  }

  Future<void> deleteAllData() async {
      await SyncInfoResository.instance.deleteAll();
      await PhotoResository.instance.deleteAll();
      await ThumbnailResository.instance.deleteAll();
      await PhotoMetadataResository.instance.deleteAll();
      await VideoResository.instance.deleteAll();
      await VideoMetadataResository.instance.deleteAll();
  }
}
