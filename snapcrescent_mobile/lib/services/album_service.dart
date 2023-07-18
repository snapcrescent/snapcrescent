import 'package:dio/dio.dart';
import 'package:snapcrescent_mobile/models/album/album.dart';
import 'package:snapcrescent_mobile/models/album/album_search_criteria.dart';
import 'package:snapcrescent_mobile/models/common/base_response_bean.dart';
import 'package:snapcrescent_mobile/repository/album_repository.dart';
import 'package:snapcrescent_mobile/repository/thumbnail_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/services/thumbnail_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AlbumService extends BaseService {
  AlbumService._privateConstructor() : super();
  static final AlbumService instance = AlbumService._privateConstructor();

  bool executionInProgress = false;

  Future<BaseResponseBean<int, Album>> search(
      AlbumSearchCriteria searchCriteria) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/album',
            queryParameters: searchCriteria.toMap(), options: options);

        return BaseResponseBean.fromJson(response.data, Album.fromJsonModel);
      } else {
        return new BaseResponseBean.defaultResponse();
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectionTimeout) {
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
    return new List<Album>.from(data.objects!);
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

  Future<int> saveOnLocal(Album entity, bool createIfNotFound, Function progressCallBack,int assetIndex) async {
    final albumExistsById =
        await AlbumRepository.instance.existsById(entity.id!);

    if (albumExistsById == false) {
      final albumThumbnailExistsById = await ThumbnailRepository.instance.existsById(entity.albumThumbnailId!);

      if (albumThumbnailExistsById == false) {
        await ThumbnailService.instance.writeThumbnailFile(entity.albumThumbnail!);

        if(createIfNotFound) {
          ThumbnailRepository.instance.save(entity.albumThumbnail!);
        }
      } else{
        ThumbnailRepository.instance.update(entity.albumThumbnail!);
      }

      if(createIfNotFound) {
        progressCallBack(assetIndex + 1);
        return AlbumRepository.instance.save(entity);
      }
      
      return Future.value(0);
    } else {
      AlbumRepository.instance.update(entity);
      progressCallBack(assetIndex + 1);
      return Future.value(0);
    }
  }


  

  Future<int> countOnLocal() async {
    return AlbumRepository.instance.countOnLocal(AlbumSearchCriteria.defaultCriteria());
  }

  Future<List<Album>> searchOnLocal(
      AlbumSearchCriteria assetSearchCriteria) async {
    return AlbumRepository.instance.searchOnLocal(assetSearchCriteria);
  }


  Future<void> deleteAllData() async {
    await AlbumRepository.instance.deleteAll();
  }

}
