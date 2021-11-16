import 'package:dio/dio.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/sync_info_search_criteria.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';
import 'package:snap_crescent/repository/asset_repository.dart';
import 'package:snap_crescent/repository/sync_info_repository.dart';
import 'package:snap_crescent/repository/thumbnail_repository.dart';
import 'package:snap_crescent/services/base_service.dart';

class SyncInfoService extends BaseService {
  Future<BaseResponseBean<int, SyncInfo>> search(
      SyncInfoSearchCriteria searchCriteria) async {
    try {
      bool isUserLoggedIn = await super.isUserLoggedIn();

      if (isUserLoggedIn) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/sync-info',
            queryParameters: searchCriteria.toMap(), options: options);

        return BaseResponseBean.fromJson(response.data, SyncInfo.fromJsonModel);
      } else {
        return new BaseResponseBean.defaultResponse();
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  Future<int> saveOnLocal(SyncInfo entity) async {
    final syncInfoExistsById =
        await SyncInfoRepository.instance.existsById(entity.id!);

    if (syncInfoExistsById == false) {
      return SyncInfoRepository.instance.save(entity);
    } else {
      return Future.value(0);
    }
  }

  Future<List<SyncInfo>> searchOnLocal() async {
    final localSyncInfosMap = await SyncInfoRepository.instance.findAll();
    return new List<SyncInfo>.from(localSyncInfosMap
        .map((syncInfoMap) => SyncInfo.fromMap(syncInfoMap))
        .toList());
  }

  Future<void> deleteAllData() async {
    await SyncInfoRepository.instance.deleteAll();
    await ThumbnailRepository.instance.deleteAll();
    await MetadataRepository.instance.deleteAll();
    await AssetRepository.instance.deleteAll();
  }
}
