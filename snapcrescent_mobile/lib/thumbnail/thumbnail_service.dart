import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail_repository.dart';
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

  String getThumbnailByIdUrl(String? serverURL, int thumbnailId) {
    return '$serverURL/thumbnail/$thumbnailId';
  }

  Future<void> saveOnLocal(Thumbnail entity) async {
    ThumbnailRepository().saveOrUpdate(entity);
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


class ThumbnailFileDownloaderJob extends PooledJob<void> {

  final Thumbnail thumbnail;
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

  ThumbnailFileDownloaderJob(this.thumbnail);

  @override
  Future<void> job() async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await ThumbnailService().writeThumbnailFile(thumbnail);
  }
}
