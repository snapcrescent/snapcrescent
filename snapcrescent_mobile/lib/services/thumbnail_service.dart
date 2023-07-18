import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snapcrescent_mobile/models/thumbnail/thumbnail.dart';
import 'package:snapcrescent_mobile/repository/thumbnail_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/common_utilities.dart';

class ThumbnailService extends BaseService{

  ThumbnailService._privateConstructor():super();
  static final ThumbnailService instance = ThumbnailService._privateConstructor();

  Future<File> readThumbnailFile(String name) async {
    String directory = await CommonUtilities().getThumbnailDirectory();
    return File('$directory/$name');
  }

  Future<void> writeThumbnailFile(Thumbnail thumbnail) async {
    try {
      File thumbnailFile = await ThumbnailService.instance.readThumbnailFile(thumbnail.name!);
      if (!thumbnailFile.existsSync()) {
        Dio dio = await getDio();

        final url = ThumbnailService.instance.getThumbnailByIdUrl(await getServerUrl(), thumbnail.id!);

        String directory = await CommonUtilities().getThumbnailDirectory();
        await download(dio, url, '$directory/${thumbnail.name}');
      }
    } on DioError catch (ex) {
      print(ex.message);
      if (ex.type == DioErrorType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      
      throw Exception(ex.message);
    }
  }

  String getThumbnailByIdUrl(String serverURL, int thumbnailId) {
    return serverURL + '/thumbnail/$thumbnailId';
  }
  
  Future<int> saveOnLocal(Thumbnail entity) async {
    return ThumbnailRepository.instance.save(entity);
  }

  Future<Thumbnail> findByIdOnLocal(int id) async {
    final result = await  ThumbnailRepository.instance.findById(id);
    return Thumbnail.fromMap(result);
  }

}
