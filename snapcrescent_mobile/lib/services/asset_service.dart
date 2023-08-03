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
import 'package:snapcrescent_mobile/services/notification_service.dart';
import 'package:snapcrescent_mobile/services/thumbnail_service.dart';
import 'package:snapcrescent_mobile/state/asset_state.dart';
import 'package:snapcrescent_mobile/utils/common_utilities.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:mime/mime.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class AssetService extends BaseService {
  static final AssetService _singleton = AssetService._internal();

  factory AssetService() {
    return _singleton;
  }

  AssetService._internal();

  bool executionInProgress = false;

  Future<BaseResponseBean<int, Asset>> search(
      AssetSearchCriteria searchCriteria) async {
    try {
      if (await super.isUserLoggedIn()) {
        Dio dio = await getDio();
        Options options = await getHeaders();
        final response = await dio.get('/asset',
            queryParameters: searchCriteria.toJson(), options: options);

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

  Future<List<Asset>> searchAndSync(
      AssetSearchCriteria searchCriteria, Function progressCallBack) async {
    searchCriteria.sortOrder = Direction.DESC;
    final data = await search(searchCriteria);
    await saveAllOnLocal(data.objects!, progressCallBack);
    return List<Asset>.from(data.objects!);
  }

  Future<List<Asset>> searchAndSyncInactiveRecords(
      AssetSearchCriteria searchCriteria) async {
    searchCriteria.sortOrder = Direction.ASC;
    searchCriteria.active = false;
    final data = await search(searchCriteria);

    for (Asset entity in data.objects!) {
      await saveOnLocal(entity, false, () => {}, 0);
    }

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
        final url = downloadAssetByIdUrl(await getServerUrl(), response.object!.token!);

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
    executionInProgress = false;
  }

  Future<int> saveAllOnLocal(
      List<Asset> entities, Function progressCallBack) async {
    executionInProgress = true;
    for (Asset entity in entities) {
      if (executionInProgress) {
        await saveOnLocal(
            entity, true, progressCallBack, entities.indexOf(entity));
      }
    }

    return Future.value(0);
  }

  Future<int> saveOnLocal(Asset entity, bool createIfNotFound,
      Function progressCallBack, int assetIndex) async {
    final assetExistsById = await AssetRepository().existsById(entity.id!);

    if (assetExistsById == false) {
      final thumbnailExistsById =
          await ThumbnailRepository().existsById(entity.thumbnailId!);

      if (thumbnailExistsById == false) {
        await ThumbnailService().writeThumbnailFile(entity.thumbnail!);

        if (createIfNotFound) {
          ThumbnailRepository().saveOrUpdate(entity.thumbnail!);
        }
      } else {
        ThumbnailRepository().saveOrUpdate(entity.thumbnail!);
      }

      final assetMetadataExistsById =
          await MetadataRepository().existsById(entity.metadataId!);

      if (assetMetadataExistsById == false) {
        if (createIfNotFound) {
          MetadataRepository().saveOrUpdate(entity.metadata!);
        }
      } else {
        MetadataRepository().saveOrUpdate(entity.metadata!);
      }

      if (createIfNotFound) {
        progressCallBack(assetIndex + 1);
        return AssetRepository().saveOrUpdate(entity);
      }

      return Future.value(0);
    } else {
      AssetRepository().saveOrUpdate(entity);
      progressCallBack(assetIndex + 1);
      return Future.value(0);
    }
  }

  Future<int> countOnLocal() async {
    return AssetRepository()
        .countOnLocal(AssetSearchCriteria.defaultCriteria());
  }

  Future<List<Asset>> searchOnLocal(
      AssetSearchCriteria assetSearchCriteria) async {
    return AssetRepository().searchOnLocal(assetSearchCriteria);
  }

  Future<DateTime?> getLatestAssetDate() async {
    List<Asset> localAssetsList =
        await searchOnLocal(AssetSearchCriteria.defaultCriteria());

    DateTime? latestAssetDate;

    if (localAssetsList.isEmpty == false) {
      Asset latestAsset = localAssetsList.first;
      final metadata =
          await MetadataService().findById(latestAsset.metadataId!);
      latestAsset.metadata = metadata;

      latestAssetDate = latestAsset.metadata!.creationDateTime!;
    }

    return latestAssetDate;
  }

  Future<void> deleteAllData() async {
    await AssetRepository().deleteAll();
    await ThumbnailService().deleteAll();
    await MetadataRepository().deleteAll();
  }

  Future<void> deleteUploadedAssets(DateTime tillDate) async {
    List<Metadata>? localAssetsSyncedWithServer = await MetadataService().findByLocalAssetIdNotNull();

    if (localAssetsSyncedWithServer != null &&
        localAssetsSyncedWithServer.isNotEmpty) {

      localAssetsSyncedWithServer = localAssetsSyncedWithServer.where((metadata) => DateUtilities().isBefore(metadata.creationDateTime!, tillDate) ).toList();
      
      
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

            if(assetFile != null && assetFile.existsSync()) {
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
    NotificationService().showProgressNotification("Downloading", "Downloading files on device", assetIndexes.length, 0);
    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset =
          AssetState().assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        await permanentDownloadAssetById(asset.id!, asset.metadata!.name!, unifiedAsset.assetType);
        NotificationService().showProgressNotification("Downloading", "Downloading files on device", assetIndexes.length, assetIndexes.indexOf(assetIndex));
      }
    }
    NotificationService().showProgressNotification("Downloading", "Downloading files on device", assetIndexes.length, assetIndexes.length);
    NotificationService().clearNotifications();
    NotificationService().showNotification("Download Complete", "Download Complete");
    return true;
  }

  _getAssetFile(List<int> assetIndexes) async {
    List<File> assetFiles = [];

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset =
          AssetState().assetList[assetIndex];

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
      final UniFiedAsset unifiedAsset =
          AssetState().assetList[assetIndex];

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
