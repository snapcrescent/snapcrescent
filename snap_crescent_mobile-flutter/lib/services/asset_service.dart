import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quiver/iterables.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/thumbnail.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';
import 'package:snap_crescent/repository/asset_repository.dart';
import 'package:snap_crescent/repository/thumbnail_repository.dart';
import 'package:snap_crescent/services/base_service.dart';
import 'package:snap_crescent/services/metadata_service.dart';
import 'package:snap_crescent/utils/common_utilities.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetService extends BaseService {
  AssetService._privateConstructor() : super();
  static final AssetService instance = AssetService._privateConstructor();

  bool executionInProgress = false;

  Future<BaseResponseBean<int, Asset>> search(
      AssetSearchCriteria searchCriteria) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/asset',
            queryParameters: searchCriteria.toMap(), options: options);

        return BaseResponseBean.fromJson(response.data, Asset.fromJsonModel);
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

  save(List<File> files) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();

        final Iterable<List<File>> partitionedFiles = partition(files, 5);

        for (final partitionedFile in partitionedFiles) {
          List<MultipartFile> multipartFiles = [];
          for (final File file in partitionedFile) {
            multipartFiles.add(await MultipartFile.fromFile(file.path,
                filename: file.path.split('/').last));
          }

          FormData formData = FormData.fromMap({
            "files": multipartFiles,
          });
          await dio.post("/asset/upload", data: formData, options: options);
        }
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }

    return Future.value(true);
  }

  Future<List<Asset>> searchAndSync(
      AssetSearchCriteria searchCriteria, 
      Function progressCallBack) async {
    searchCriteria.sortOrder = Direction.ASC;
    final data = await search(searchCriteria);
    await saveAllOnLocal(data.objects!, progressCallBack);
    return new List<Asset>.from(data.objects!);
  }

  Future<List<Asset>> searchAndSyncInactiveRecords(
      AssetSearchCriteria searchCriteria) async {
    searchCriteria.sortOrder = Direction.ASC;
    searchCriteria.active = false;
    final data = await search(searchCriteria);

    for (Asset entity in data.objects!) {
          await saveOnLocal(entity, false, () => {}, 0);
    }

    return new List<Asset>.from(data.objects!);
  }

  String getAssetByIdUrl(String serverURL, int assetId) {
    return serverURL + '/asset/$assetId/stream';
  }

 

  Future<bool> permanentDownloadAssetById(int assetId, String assetName) async {
      File? tempDownloadedFile = await tempDownloadAssetById(assetId, assetName);
      String downloadPath = await CommonUtilities().getPermanentDownloadsDirectory();
      
      if(tempDownloadedFile != null) {
          tempDownloadedFile.copySync('$downloadPath/$assetName');
          tempDownloadedFile.deleteSync();
      }
      
      return true;
  }

  Future<File?> tempDownloadAssetById(int assetId, String assetName) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final url = getAssetByIdUrl(await getServerUrl(), assetId);

        String directory = await CommonUtilities().getTempDownloadsDirectory();
        String fullPath = '$directory/$assetName';
        await download(dio, url, options, fullPath);
        File file = new File(fullPath);
        return file;
      } else {
        return new File("");
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  cancelSyncProcess() {
    executionInProgress = false;
  }

  Future<int> saveAllOnLocal(
      List<Asset> entities, Function progressCallBack) async {
    executionInProgress = true;
    for (Asset entity in entities) {
      if(executionInProgress) {
          await saveOnLocal(entity, true, progressCallBack, entities.indexOf(entity));
      }
    }

    return Future.value(0);
  }

  Future<int> saveOnLocal(Asset entity, bool createIfNotFound, Function progressCallBack,int assetIndex) async {
    final assetExistsById =
        await AssetRepository.instance.existsById(entity.id!);

    if (assetExistsById == false) {
      final thumbnailExistsById =
          await ThumbnailRepository.instance.existsById(entity.thumbnailId!);

      if (thumbnailExistsById == false) {
        await _writeThumbnailFile(entity.thumbnail!);

        if(createIfNotFound) {
          ThumbnailRepository.instance.save(entity.thumbnail!);
        }
      } else{
        ThumbnailRepository.instance.update(entity.thumbnail!);
      }

      final assetMetadataExistsById =
          await MetadataRepository.instance.existsById(entity.metadataId!);

      if (assetMetadataExistsById == false) {
        if(createIfNotFound) {
          MetadataRepository.instance.save(entity.metadata!);
        }
      } else {
        MetadataRepository.instance.update(entity.metadata!);
      }

      if(createIfNotFound) {
        progressCallBack(assetIndex);
        return AssetRepository.instance.save(entity);
      }
      
      return Future.value(0);
    } else {
      AssetRepository.instance.update(entity);
      progressCallBack(assetIndex);
      return Future.value(0);
    }
  }

  Future<File> readThumbnailFile(String name) async {
    String directory = await CommonUtilities().getThumbnailDirectory();
    return File('$directory/$name');
  }

  String getThumbnailByIdUrl(String serverURL, int thumbnailId) {
    return serverURL + '/thumbnail/$thumbnailId';
  }

  Future<void> _writeThumbnailFile(Thumbnail thumbnail) async {
    try {
      File thumbnailFile = await readThumbnailFile(thumbnail.name!);
      if (!thumbnailFile.existsSync()) {
        Dio dio = await getDio();

        Options options = await getHeaders();
        final url = getThumbnailByIdUrl(await getServerUrl(), thumbnail.id!);

        String directory = await CommonUtilities().getThumbnailDirectory();
        await download(dio, url, options, '$directory/${thumbnail.name}');
      }
    } on DioError catch (ex) {
      print(ex.message);
      if (ex.type == DioErrorType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      
      throw Exception(ex.message);
    }
  }

  Future<int> countOnLocal() async {
    return AssetRepository.instance.countOnLocal(AssetSearchCriteria.defaultCriteria());
  }

  Future<List<Asset>> searchOnLocal(
      AssetSearchCriteria assetSearchCriteria) async {
    return AssetRepository.instance.searchOnLocal(assetSearchCriteria);
  }

  Future<DateTime?> getLatestAssetDate() async {
    List<Asset> localAssetsList = await AssetService.instance.searchOnLocal(AssetSearchCriteria.defaultCriteria());

    DateTime? _latestAssetDate;

    if (localAssetsList.isEmpty == false) {

      Asset latestAsset = localAssetsList.first;
      final metadata = await MetadataService.instance.findByIdOnLocal(latestAsset.metadataId!);
      latestAsset.metadata = metadata;

      _latestAssetDate = latestAsset.metadata!.creationDateTime!;
    } 

    return _latestAssetDate;
  }


    Future<void> deleteAllData() async {
    await AssetRepository.instance.deleteAll();
    await ThumbnailRepository.instance.deleteAll();
    await MetadataRepository.instance.deleteAll();
  }
}
