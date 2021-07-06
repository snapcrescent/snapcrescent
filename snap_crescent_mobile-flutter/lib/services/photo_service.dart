import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    
    if (response.statusCode == 200) {
      return BaseResponseBean.fromJson(jsonDecode(response.body), Photo.fromJsonModel);
    } else {
      throw "Unable to retrieve photos.";
    }
  }

  Future<List<Photo>> searchAndSync(PhotoSearchCriteria searchCriteria) async{
      final data = await PhotoService().search(searchCriteria);
      await saveAllOnLocal(data.objects!);
      return new List<Photo>.from(data.objects!);
  }

  Future<String> getGenericPhotoByIdUrl() async {
    final baseUrl = await getServerUrl();
    return '''$baseUrl/photo/PHOTO_ID/raw''';
  }

  String getPhotoByIdUrl(String genericURL, int photoId)  {
    return genericURL.replaceAll("PHOTO_ID", photoId.toString());
  }

  Future<File> downloadPhotoById(int photoId,String photoName) async{
    final _genericPhotoByIdUrl =  await getGenericPhotoByIdUrl();
    final url = getPhotoByIdUrl(_genericPhotoByIdUrl, photoId);
    final response = await get(Uri.parse(url));
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    File file = new File(join(documentDirectory.path, photoName));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
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
  
}
