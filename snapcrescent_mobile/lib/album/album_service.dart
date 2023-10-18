import 'package:dio/dio.dart';
import 'package:snapcrescent_mobile/album/album.dart';
import 'package:snapcrescent_mobile/album/album_repository.dart';
import 'package:snapcrescent_mobile/album/album_search_criteria.dart';
import 'package:snapcrescent_mobile/common/model/base_response_bean.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail_repository.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AlbumService extends BaseService {
 static final AlbumService _singleton = AlbumService._internal();

  factory AlbumService() {
    return _singleton;
  }

  AlbumService._internal();

  bool executionInProgress = false;

  Future<BaseResponseBean<int, Album>> search(
      AlbumSearchCriteria searchCriteria) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/album',
            queryParameters: searchCriteria.toJson(), options: options);

        return BaseResponseBean.fromJson(response.data, Album.fromJsonModel);
      } else {
        return BaseResponseBean.defaultResponse();
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  Future<List<Album>> searchAndSync(
      AlbumSearchCriteria  searchCriteria, 
      Function progressCallBack) async {
    searchCriteria.sortOrder = Direction.ASC;
    final data = await search(searchCriteria);
    await saveAllOnLocal(data.objects!, progressCallBack);
    return List<Album>.from(data.objects!);
  }


  cancelSyncProcess() {
    executionInProgress = false;
  }

  Future<int> saveAllOnLocal(
      List<Album> entities, Function progressCallBack) async {
    executionInProgress = true;
    for (Album entity in entities) {
      if(executionInProgress) {
          await saveOnLocal(entity, true, progressCallBack, entities.indexOf(entity));
      }
    }

    return Future.value(0);
  }

  Future<void> saveOnLocal(Album entity, bool createIfNotFound, Function progressCallBack,int assetIndex) async {
    final albumExistsById =
        await AlbumRepository().existsById(entity.id!);

    if (albumExistsById == false) {
      final albumThumbnailExistsById = await ThumbnailRepository().existsById(entity.albumThumbnailId!);

      if (albumThumbnailExistsById == false) {
        await ThumbnailService().writeThumbnailFile(entity.albumThumbnail!);

        if(createIfNotFound) {
          ThumbnailRepository().saveOrUpdate(entity.albumThumbnail!);
        }
      } else{
        ThumbnailRepository().saveOrUpdate(entity.albumThumbnail!);
      }

      if(createIfNotFound) {
        progressCallBack(assetIndex + 1);
        AlbumRepository().saveOrUpdate(entity);
      }
      
    } else {
      AlbumRepository().saveOrUpdate(entity);
      progressCallBack(assetIndex + 1);
    }
  }


  

  Future<int> countOnLocal() async {
    return AlbumRepository().countOnLocal(AlbumSearchCriteria.defaultCriteria());
  }

  Future<List<Album>> searchOnLocal(
      AlbumSearchCriteria assetSearchCriteria) async {
    return AlbumRepository().searchOnLocal(assetSearchCriteria);
  }


  Future<void> deleteAllData() async {
    await AlbumRepository().deleteAll();
  }

}
