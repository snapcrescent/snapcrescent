import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/photo.dart';
import 'package:snap_crescent/models/photo_search_criteria.dart';
import 'package:snap_crescent/resository/photo_metadata_resository.dart';
import 'package:snap_crescent/resository/photo_resository.dart';
import 'package:snap_crescent/resository/thumbnail_resository.dart';
import 'package:snap_crescent/services/base_service.dart';

class PhotoService extends BaseService {
  Future<BaseResponseBean<int, Photo>> search(
      PhotoSearchCriteria searchCriteria) async {
    try {
      Dio dio = await getDio();
      final response = await dio.get('/photo',  queryParameters : searchCriteria.toMap());

      return BaseResponseBean.fromJson(response.data, Photo.fromJsonModel);
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  Future<List<Photo>> searchAndSync(PhotoSearchCriteria searchCriteria) async {
    final data = await PhotoService().search(searchCriteria);
    await saveAllOnLocal(data.objects!);
    return new List<Photo>.from(data.objects!);
  }

  Future<String> getGenericPhotoByIdUrl() async {
    final baseUrl = await getServerUrl();
    return '''$baseUrl/photo/PHOTO_ID/raw''';
  }

  String getPhotoByIdUrl(String genericURL, int photoId) {
    return genericURL.replaceAll("PHOTO_ID", photoId.toString());
  }

  Future<File> downloadPhotoById(int photoId, String photoName) async {
    final _genericPhotoByIdUrl = await getGenericPhotoByIdUrl();
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
    final photoExistsById =
        await PhotoResository.instance.existsById(entity.id!);

    if (photoExistsById == false) {
      final thumbnailExistsById =
          await ThumbnailResository.instance.existsById(entity.thumbnailId!);

      if (thumbnailExistsById == false) {
        ThumbnailResository.instance.save(entity.thumbnail!);
      }

      final photoMetadataExistsById =
          await PhotoMetadataResository.instance.existsById(entity.photoMetadataId!);

      if (photoMetadataExistsById == false) {
        PhotoMetadataResository.instance.save(entity.photoMetadata!);
      }

      return PhotoResository.instance.save(entity);
    } else {
      return Future.value(0);
    }
  }

  Future<List<Photo>> searchOnLocal() async {
    return PhotoResository.instance.searchOnLocal(); 
  }
}
