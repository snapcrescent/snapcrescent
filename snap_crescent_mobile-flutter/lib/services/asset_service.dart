import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quiver/iterables.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/base_response_bean.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';
import 'package:snap_crescent/repository/asset_repository.dart';
import 'package:snap_crescent/repository/thumbnail_repository.dart';
import 'package:snap_crescent/services/base_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class AssetService extends BaseService {
  Future<BaseResponseBean<int, Asset>> search(
      AssetSearchCriteria searchCriteria) async {
    try {
      
      if (await  super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/asset', queryParameters: searchCriteria.toMap(), options: options);

        return BaseResponseBean.fromJson(response.data, Asset.fromJsonModel);
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

  save(ASSET_TYPE assetType, List<File> files) async {
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
            "assetType": assetType.index,
            "files": multipartFiles,
          });
          await dio.post("/asset/upload", data: formData, options: options);
        }
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }

    return Future.value(true);
  }

  Future<List<Asset>> searchAndSync(AssetSearchCriteria searchCriteria) async {
    final data = await AssetService().search(searchCriteria);
    await saveAllOnLocal(data.objects!);
    return new List<Asset>.from(data.objects!);
  }

  String getAssetByIdUrl(String serverURL, int assetId) {
    return serverURL + '/asset/$assetId/raw';
  }

  Future<File> downloadAssetById(int assetId, String assetName) async {
    try {
      
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final url = getAssetByIdUrl(await getServerUrl(), assetId);
        Directory documentDirectory = await getApplicationDocumentsDirectory();
        await dio.download(url, join(documentDirectory.path, assetName), options: options);
        File file = new File(join(documentDirectory.path, assetName));
        return file;
      } else {
        return new File("");
      }
    } on DioError catch (ex) {
      if (ex.type == DioErrorType.connectTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  Future<int> saveAllOnLocal(List<Asset> entities) async {
    entities.forEach((entity) {
      saveOnLocal(entity);
    });

    return Future.value(0);
  }

  Future<int> saveOnLocal(Asset entity) async {
    final assetExistsById =
        await AssetRepository.instance.existsById(entity.id!);

    if (assetExistsById == false) {
      final thumbnailExistsById =
          await ThumbnailRepository.instance.existsById(entity.thumbnailId!);

      if (thumbnailExistsById == false) {
        ThumbnailRepository.instance.save(entity.thumbnail!);
      }

      final assetMetadataExistsById =
          await MetadataRepository.instance.existsById(entity.metadataId!);

      if (assetMetadataExistsById == false) {
        MetadataRepository.instance.save(entity.metadata!);
      }

      return AssetRepository.instance.save(entity);
    } else {
      return Future.value(0);
    }
  }

  Future<List<Asset>> searchOnLocal(
      AssetSearchCriteria assetSearchCriteria) async {
    return AssetRepository.instance.searchOnLocal(assetSearchCriteria);
  }

  saveOnCloud() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigAutoBackupFolders);

    if (value.configValue != null) {
      final List<AssetPathEntity> folders =
          await PhotoManager.getAssetPathList();
      folders.sort(
          (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

      List<String> autoBackupFolderNameList = value.configValue!.split(",");
      List<AssetPathEntity> autoBackupFolders = [];

      for (int i = 0; i < folders.length; i++) {
        if (autoBackupFolderNameList.indexOf(folders[i].id) > -1) {
          autoBackupFolders.add(folders[i]);
        }
      }

      for (int i = 0; i < autoBackupFolders.length; i++) {
        AssetPathEntity folder = autoBackupFolders[i];

        final allAssets = await folder.getAssetListRange(
          start: 0, // start at index 0
          end: 100000, // end at a very big index (to get all the assets)
        );

        final photos =
            allAssets.where((asset) => asset.type == AssetType.image);

        List<File> assetFiles = [];
        for (final AssetEntity asset in photos) {
          final File? assetFile = await asset.file;
          assetFiles.add(assetFile!);
        }

        save(ASSET_TYPE.PHOTO, assetFiles);
      }
    }
  }
}
