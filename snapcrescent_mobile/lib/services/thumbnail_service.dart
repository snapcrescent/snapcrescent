import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snapcrescent_mobile/models/thumbnail/thumbnail.dart';
import 'package:snapcrescent_mobile/repository/thumbnail_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/common_utilities.dart';

class ThumbnailService extends BaseService {
  static final ThumbnailService _singleton = ThumbnailService._internal();

  factory ThumbnailService() {
    return _singleton;
  }

  ThumbnailService._internal();

  Future<File> readThumbnailFile(String name) async {
    String directory = await CommonUtilities().getThumbnailDirectory();
    return File('$directory/$name');
  }

  Future<void> writeThumbnailFile(Thumbnail thumbnail) async {
    final thumbnailExistsById =
        await ThumbnailRepository().existsById(thumbnail.id!);

    if (thumbnailExistsById == false) {
      try {
        File thumbnailFile = await readThumbnailFile(thumbnail.name!);
        if (!thumbnailFile.existsSync()) {
          Dio dio = await getDio();

          final url = getThumbnailByIdUrl(await getServerUrl(), thumbnail.id!);

          String directory = await CommonUtilities().getThumbnailDirectory();
          await download(dio, url, '$directory/${thumbnail.name}');
        }
      } on DioException catch (ex) {
        print(ex.message);
        if (ex.type == DioExceptionType.connectionTimeout) {
          throw Exception("Connection  Timeout Exception");
        }

        throw Exception(ex.message);
      }
    }
  }

  String getThumbnailByIdUrl(String? serverURL, int thumbnailId) {
    return '$serverURL/thumbnail/$thumbnailId';
  }

  Future<int> saveOnLocal(Thumbnail entity) async {
    return ThumbnailRepository().saveOrUpdate(entity);
  }

  Future<Thumbnail?> findByIdOnLocal(int id) async {
    final result = await ThumbnailRepository().findById(id);

    if (result != null) {
      return Thumbnail.fromMap(result);
    } else {
      return null;
    }
  }

  Future<void> deleteAll() async {
    String directory = await CommonUtilities().getThumbnailDirectory();
    Directory thumbnailDirectory = Directory(directory);

    if (thumbnailDirectory.existsSync()) {
      thumbnailDirectory.deleteSync(recursive: true);
    }

    await ThumbnailRepository().deleteAll();
  }
}
