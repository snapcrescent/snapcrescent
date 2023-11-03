import 'dart:io';

import 'package:dio/dio.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/asset/asset.dart';
import 'package:snapcrescent_mobile/asset/asset_repository.dart';
import 'package:snapcrescent_mobile/asset/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/asset/asset_timeline.dart';
import 'package:snapcrescent_mobile/asset/state/asset_state.dart';
import 'package:snapcrescent_mobile/asset/unified_asset.dart';
import 'package:snapcrescent_mobile/common/model/base_response_bean.dart';
import 'package:snapcrescent_mobile/metadata/metadata.dart';
import 'package:snapcrescent_mobile/metadata/metadata_repository.dart';
import 'package:snapcrescent_mobile/metadata/metadata_service.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/services/global_service.dart';
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail_repository.dart';
import 'package:snapcrescent_mobile/thumbnail/thumbnail_service.dart';
import 'package:snapcrescent_mobile/utils/common_utilities.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:mime/mime.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class AssetService extends BaseService {
  static final AssetService _singleton = AssetService._internal();

  factory AssetService() {
    return _singleton;
  }

  
  Map<String, int> executionTimeMap = {}; 

  AssetService._internal();

  bool _cancelletionFlag = false;

  Future<BaseResponseBean<int, Asset>> search(
      AssetSearchCriteria searchCriteria) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.post('/asset/sync',
            data: searchCriteria.toJson(), options: options);

        return BaseResponseBean.fromJson(response.data, Asset.fromJsonModel);
      } else {
        return BaseResponseBean.defaultResponse();
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
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

        List<MultipartFile> multipartFiles = [];
        for (final File file in files) {
          multipartFiles.add(await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last));
        }

        FormData formData = FormData.fromMap({
          "files": multipartFiles,
        });
        await dio.post("/asset/upload", data: formData, options: options);
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }

    return Future.value(true);
  }

  Future<List<Asset>> searchAndSync(AssetSearchCriteria searchCriteria) async {
    searchCriteria.sortOrder = Direction.DESC;
    final data = await search(searchCriteria);
    
    await _saveAllOnLocal(data.objects!, true);
    
    return List<Asset>.from(data.objects!);
  }

  Future<List<Asset>> searchAndSyncInactiveRecords(
      AssetSearchCriteria searchCriteria) async {
    searchCriteria.sortOrder = Direction.ASC;
    searchCriteria.active = false;
    final data = await search(searchCriteria);

    await _saveAllOnLocal(data.objects!, false);
    
    return List<Asset>.from(data.objects!);
  }

  Future<BaseResponseBean<int, Asset>> getAssetById(int assetId) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/asset/$assetId', options: options);

        return BaseResponseBean.fromJson(response.data, Asset.fromJsonModel);
      } else {
        return BaseResponseBean.defaultResponse();
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  String streamAssetByIdUrl(String? serverURL, String token) {
    return '''$serverURL/asset/$token/stream''';
  }

  String downloadAssetByIdUrl(String? serverURL, String token) {
    return '''$serverURL/asset/$token/download''';
  }

  Future<bool> permanentDownloadAssetById(
      int assetId, String assetName, AppAssetType assetType) async {
    File? tempDownloadedFile =
        await tempDownloadAssetById(assetId, assetName, assetType);
    String downloadPath =
        await CommonUtilities().getPermanentDownloadsDirectory();

    if (tempDownloadedFile != null) {
      tempDownloadedFile.copySync('$downloadPath/$assetName');
      tempDownloadedFile.deleteSync();
    }

    return true;
  }

  Future<File?> tempDownloadAssetById(
      int assetId, String assetName, AppAssetType assetType) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();

        BaseResponseBean<int, Asset> response = await getAssetById(assetId);
        final url =
            downloadAssetByIdUrl(await getServerUrl(), response.object!.token!);

        String directory = await CommonUtilities().getTempDownloadsDirectory();
        String fullPath = '$directory/$assetName';

        if (assetType == AppAssetType.PHOTO) {
          await download(dio, url, fullPath);
        } else {
          await downloadWithChunks(dio, url, fullPath);
        }

        File file = File(fullPath);
        return file;
      } else {
        return File("");
      }
    } on DioException catch (ex) {
      if (ex.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection  Timeout Exception");
      }
      throw Exception(ex.message);
    }
  }

  cancelSyncProcess() {
    _cancelletionFlag = true;
  }

  Future<int> _saveAllOnLocal(List<Asset> entities, bool createIfNotFound ) async {
    _cancelletionFlag = false;
    executionTimeMap = {}; 

    var thumbnailDownloaderJobs = <Future>[];
    
    List<Asset> assetList = [];
    List<Thumbnail> thumbnailList = [];
    List<Metadata> metadataList = [];

    for (Asset entity in entities) {
      if (_cancelletionFlag == false) {
        Map<String,bool> result =  await saveOnLocal(entity, createIfNotFound, thumbnailDownloaderJobs);

        if(result['saveAsset'] == true) {
          assetList.add(entity);
        }

        if(result['saveThumbnail'] == true) {
          thumbnailList.add(entity.thumbnail!);
        }

        if(result['saveMetadata'] == true) {
          metadataList.add(entity.metadata!);
        }
      }
    }

    await ThumbnailRepository().saveOrUpdateAll(thumbnailList);
    await MetadataRepository().saveOrUpdateAll(metadataList);
    await AssetRepository().saveOrUpdateAll(assetList);
    
    await Future.wait(thumbnailDownloaderJobs);
    return Future.value(0);
  }

  Future<dynamic> saveOnLocal(
      Asset entity, bool createIfNotFound, List<Future> thumbnailDownloaderJobs) async {

    bool saveAsset = false;
    bool saveThumbnail = false;
    bool saveMetadata = false;

    final assetExistsById = await AssetRepository().existsById(entity.id!);
    
    if (assetExistsById == false) {
      final thumbnailExistsById =
          await ThumbnailRepository().existsById(entity.thumbnailId!);
    
      if (thumbnailExistsById == false) {
        if (createIfNotFound) {
          thumbnailDownloaderJobs.add(GlobalService.instance.pool.scheduleJob(ThumbnailFileDownloaderJob(entity.thumbnail!)));
          saveThumbnail = true;
        }
      } else {
        saveThumbnail = true;
      }

      final assetMetadataExistsById =
          await MetadataRepository().existsById(entity.metadataId!);
      if (assetMetadataExistsById == false) {
        if (createIfNotFound) {
          saveMetadata = true;
        }
      } else {
        saveMetadata = true;
      }

      if (createIfNotFound) {
        saveAsset = true;
      }
    } else {
      saveAsset = true;
    }

    return {
      'saveAsset' : saveAsset,
      'saveThumbnail' : saveThumbnail,
      'saveMetadata' : saveMetadata,
    };
  }

  Future<List<int>> assetIdsOnLocal() async {
    return AssetRepository()
        .findAllIds();
  }

  Future<int> countOnLocal() async {
    return AssetRepository()
        .countOnLocal(AssetSearchCriteria.defaultCriteria());
  }

  Future<List<Asset>> searchOnLocal(
      AssetSearchCriteria assetSearchCriteria) async {
    return AssetRepository().searchOnLocal(assetSearchCriteria);
  }

  Future<List<AssetTimeline>> getAssetTimeline() async {
    return AssetRepository().getAssetTimeline();
  }

  

  Future<int> getLatestAssetId() async {
    return AssetRepository().findMaxId();
  }

  Future<void> deleteAllData() async {
    await AssetRepository().deleteAll();
    await ThumbnailService().deleteAll();
    await MetadataRepository().deleteAll();
  }

  Future<void> deleteOnLocal(int assetId) async {
    await AssetRepository().delete(assetId);
  }

  Future<void> deleteUploadedAssets(DateTime tillDate) async {
    List<Metadata>? localAssetsSyncedWithServer =
        await MetadataService().findByLocalAssetIdNotNull();

    if (localAssetsSyncedWithServer != null &&
        localAssetsSyncedWithServer.isNotEmpty) {
      localAssetsSyncedWithServer = localAssetsSyncedWithServer
          .where((metadata) =>
              DateUtilities().isBefore(metadata.creationDateTime!, tillDate))
          .toList();

      List<String> syncedAssetIds = localAssetsSyncedWithServer
          .map((metadata) => metadata.localAssetId!)
          .toList();

      final List<AssetPathEntity> folders =
          await PhotoManager.getAssetPathList();

      for (int folderIndex = 0; folderIndex < folders.length; folderIndex++) {
        AssetPathEntity folder = folders[folderIndex];

        List<AssetEntity> assets = await folder.getAssetListRange(
          start: 0, // start at index 0
          end: 100000, // end at a very big index (to get all the assets)
        );

        for (var assetIndex = 0; assetIndex < assets.length; assetIndex++) {
          AssetEntity assetEntity = assets[assetIndex];
          if (syncedAssetIds.contains(assetEntity.id)) {
            File? assetFile = await assetEntity.file;

            if (assetFile != null && assetFile.existsSync()) {
              assetFile.deleteSync();
            }
          }
        }
      }

      for (var metadata in localAssetsSyncedWithServer) {
        metadata.localAssetId = null;
        MetadataService().saveOrUpdate(metadata);
      }
    }
  }

  Future<List<XFile>> getAssetFilesForSharing(List<int> assetIndexes) async {
    List<XFile> xFiles = [];
    List<File> assetFiles = await _getAssetFile(assetIndexes);

    for (var assetFile in assetFiles) {
      xFiles
          .add(XFile(assetFile.path, mimeType: lookupMimeType(assetFile.path)));
    }

    return xFiles;
  }

  Future<bool> downloadAssetFilesToDevice(List<int> assetIndexes) async {
    NotificationService().showProgressNotification(
        "Downloading", "Downloading files on device", assetIndexes.length, 0);
    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = AssetState().assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        await permanentDownloadAssetById(
            asset.id!, asset.metadata!.name!, unifiedAsset.assetType);
        NotificationService().showProgressNotification(
            "Downloading",
            "Downloading files on device",
            assetIndexes.length,
            assetIndexes.indexOf(assetIndex));
      }
    }
    NotificationService().showProgressNotification(
        "Downloading",
        "Downloading files on device",
        assetIndexes.length,
        assetIndexes.length);
    NotificationService().clearNotifications();
    NotificationService()
        .showNotification("Download Complete", "Download Complete");
    return true;
  }

  _getAssetFile(List<int> assetIndexes) async {
    List<File> assetFiles = [];

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = AssetState().assetList[assetIndex];

      File? assetFile;

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        assetFile = await tempDownloadAssetById(
            asset.id!, asset.metadata!.name!, unifiedAsset.assetType);
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
      final UniFiedAsset unifiedAsset = AssetState().assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.DEVICE) {
        AssetEntity asset = unifiedAsset.assetEntity!;
        File? assetFile = await asset.file;
        String filePath = assetFile!.path;
        String fileName =
            filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
        Metadata? metadata = await MetadataRepository()
            .findByNameAndSize(fileName, assetFile.lengthSync());

        if (metadata == null) {
          //The asset is not uploaded to server yet;
          await save([assetFile]);
        }
      }
    }

    return true;
  }
}
