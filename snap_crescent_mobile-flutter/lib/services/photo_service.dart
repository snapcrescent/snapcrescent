import 'dart:convert';

import 'package:http/http.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/models/photo_search_criteria.dart';
import 'package:snap_crescent/resository/photo_resository.dart';
import 'package:snap_crescent/resository/thumbnail_resository.dart';
import 'package:snap_crescent/services/base_service.dart';

class PhotoService extends BaseService {
  
  Future<BaseResponseBean<int, Photo>> search(PhotoSearchCriteria searchCriteria) async {
    final baseUrl = await getServerUrl();
    final String queryString = getQueryString(searchCriteria.toMap());

    Response response = await get(Uri.parse('''$baseUrl/photo?$queryString'''));
    //Response response = await get(Uri.parse('''$baseUrl/photo?resultType=SEARCH&page=0&size=1000&sort=photo.id&sortDirection=desc'''));

    if (response.statusCode == 200) {
      return BaseResponseBean.fromJson(jsonDecode(response.body), Photo.fromJsonModel);
    } else {
      throw "Unable to retrieve photos.";
    }
  }

  Future<List<Photo>> searchAndSync(PhotoSearchCriteria searchCriteria) async{
      final data = await PhotoService().search(PhotoSearchCriteria.defaultCriteria());
      await saveAllOnLocal(data.objects!);
      return new List<Photo>.from(data.objects!);
  }

  Future<BaseResponseBean<int, Photo>> getById(int photoId) async {
    final baseUrl = await getServerUrl();
    Response res = await get(Uri.parse('''$baseUrl/photo/$photoId'''));

    if (res.statusCode == 200) {
      return BaseResponseBean.fromJson(jsonDecode(res.body), Photo.fromJsonModel);
    } else {
      throw "Unable to retrieve photo.";
    }
  }

  Future<int> saveAllOnLocal(List<Photo> entities) async {
    entities.forEach((entity) {
      saveOnLocal(entity);
     });

    return Future.value(0);

  }

  Future<int> saveOnLocal(Photo entity) async {
    final photoExistsById = await PhotoResository.instance.existsById(entity.id!);

    if(photoExistsById == false) {
      final thumbnailExistsById = await ThumbnailResository.instance.existsById(entity.thumbnailId!);

      if(thumbnailExistsById == false) {
          ThumbnailResository.instance.save(entity.thumbnail!);
      }
      
      return PhotoResository.instance.save(entity);
    } else {
      return Future.value(0);
    } 
  }

  Future<List<Photo>> searchOnLocal() async {
    final localPhotosMap =  await PhotoResository.instance.findAll();
    return new List<Photo>.from(localPhotosMap.map((photoMap) => Photo.fromMap(photoMap)).toList());
  }

  Future<int> findNextById(int photoId) async {
    return PhotoResository.instance.findNextById(photoId);
  }

  Future<int> findPreviousById(int photoId) async {
    return PhotoResository.instance.findPreviousById(photoId);
  }
  
}
