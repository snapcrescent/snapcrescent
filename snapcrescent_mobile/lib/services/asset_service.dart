import 'dart:io';

import 'package:dio/dio.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quiver/iterables.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/models/asset/asset.dart';
import 'package:snapcrescent_mobile/models/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/models/common/base_response_bean.dart';
import 'package:snapcrescent_mobile/models/metadata/metadata.dart';
import 'package:snapcrescent_mobile/models/unified_asset.dart';
import 'package:snapcrescent_mobile/repository/metadata_repository.dart';
import 'package:snapcrescent_mobile/repository/asset_repository.dart';
import 'package:snapcrescent_mobile/repository/thumbnail_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/services/metadata_service.dart';
import 'package:snapcrescent_mobile/services/thumbnail_service.dart';
import 'package:snapcrescent_mobile/state/asset_state.dart';
import 'package:snapcrescent_mobile/utils/common_utilities.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:mime/mime.dart';

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
    searchCriteria.sortOrder = Direction.DESC;
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

  Future<BaseResponseBean<int, Asset>> getAssetById(int assetId) async  {

  try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/asset/$assetId', options: options);

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

  String streamAssetByIdUrl(String serverURL, String token) {
    return serverURL + '/asset/$token/stream';
  }

  String downloadAssetByIdUrl(String serverURL, String token) {
    return serverURL + '/asset/$token/download';
  }

  Future<bool> permanentDownloadAssetById(int assetId, String assetName, AppAssetType assetType) async {
      File? tempDownloadedFile = await tempDownloadAssetById(assetId, assetName, assetType);
      String downloadPath = await CommonUtilities().getPermanentDownloadsDirectory();
      
      if(tempDownloadedFile != null) {
          tempDownloadedFile.copySync('$downloadPath/$assetName');
          tempDownloadedFile.deleteSync();
      }
      
      return true;
  }

  Future<File?> tempDownloadAssetById(int assetId, String assetName, AppAssetType assetType) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();

        BaseResponseBean<int, Asset> response = await getAssetById(assetId);
        final url = downloadAssetByIdUrl(await getServerUrl(), response.object!.token!);

        String directory = await CommonUtilities().getTempDownloadsDirectory();
        String fullPath = '$directory/$assetName';

        if(assetType == AppAssetType.PHOTO) {
          await download(dio, url, fullPath);
        } else{
          await downloadWithChunks(dio, url, fullPath);
        }
        
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
        await ThumbnailService.instance.writeThumbnailFile(entity.thumbnail!);

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
        progressCallBack(assetIndex + 1);
        return AssetRepository.instance.save(entity);
      }
      
      return Future.value(0);
    } else {
      AssetRepository.instance.update(entity);
      progressCallBack(assetIndex + 1);
      return Future.value(0);
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
    List<Asset> localAssetsList = await this.searchOnLocal(AssetSearchCriteria.defaultCriteria());

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



  Future<List<XFile>> getAssetFilesForSharing(List<int> assetIndexes) async {
    List<XFile> xFiles = [];
    List<File> assetFiles = await _getAssetFile(assetIndexes);

    for (var assetFile in assetFiles) {
      xFiles.add(XFile(assetFile.path, mimeType:lookupMimeType(assetFile.path)));
    }

    return xFiles;
  }



  Future<bool> downloadAssetFilesToDevice(List<int> assetIndexes) async {

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = AssetState.instance.assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
          Asset asset = unifiedAsset.asset!;
          await this.permanentDownloadAssetById(asset.id!, asset.metadata!.name!, unifiedAsset.assetType);
        }
    }

    return true;
  }

  _getAssetFile(List<int> assetIndexes) async {
    List<File> assetFiles = [];

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = AssetState.instance.assetList[assetIndex];

      File? assetFile;

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        assetFile = await this
            .tempDownloadAssetById(asset.id!, asset.metadata!.name!, unifiedAsset.assetType);
      } else {
        AssetEntity asset = unifiedAsset.assetEntity!;
        assetFile = await asset.file;
      }

      if (assetFile != null) {
        assetFiles.add(assetFile);
      }
    }

    return assetFiles;
  }

  Future<bool> uploadAssetFilesToServer(List<int> assetIndexes) async {

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = AssetState.instance.assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.DEVICE) {
          AssetEntity asset = unifiedAsset.assetEntity!;
          File? assetFile  = await asset.file;
          String filePath = assetFile!.path;
          String fileName = filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
          Metadata? metadata = await MetadataRepository.instance.findByNameAndSize(fileName, assetFile.lengthSync());
        
          if (metadata == null) {
            //The asset is not uploaded to server yet;
            await this.save([assetFile]);
          }
        }
    }

    return true;
  }
}
