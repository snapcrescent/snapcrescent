import 'package:dio/dio.dart';
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
  Future<BaseResponseBean<int, SyncInfo>> search(
      SyncInfoSearchCriteria searchCriteria) async {
    try {
      Dio dio = await getDio();
      final response = await dio.get('/sync-info', queryParameters: searchCriteria.toMap());

      return BaseResponseBean.fromJson(response.data, SyncInfo.fromJsonModel);
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  Future<int> saveOnLocal(SyncInfo entity) async {
    final syncInfoExistsById =
        await SyncInfoResository.instance.existsById(entity.id!);

    if (syncInfoExistsById == false) {
      return SyncInfoResository.instance.save(entity);
    } else {
      return Future.value(0);
    }
  }

  Future<List<SyncInfo>> searchOnLocal() async {
    final localSyncInfosMap = await SyncInfoResository.instance.findAll();
    return new List<SyncInfo>.from(localSyncInfosMap
        .map((syncInfoMap) => SyncInfo.fromMap(syncInfoMap))
        .toList());
  }

  Future<void> deleteAllData() async {
    await SyncInfoResository.instance.deleteAll();
    
    await ThumbnailResository.instance.deleteAll();
    await PhotoMetadataResository.instance.deleteAll();
    await PhotoResository.instance.deleteAll();

    await VideoMetadataResository.instance.deleteAll();
    await VideoResository.instance.deleteAll();
    
  }
}
