import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/models/asset.dart';
import 'package:snapcrescent_mobile/models/asset_search_criteria.dart';
import 'package:snapcrescent_mobile/models/metadata.dart';
import 'package:snapcrescent_mobile/models/unified_asset.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/repository/metadata_repository.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/asset_service.dart';
import 'package:snapcrescent_mobile/services/metadata_service.dart';
import 'package:snapcrescent_mobile/services/thumbnail_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:collection/collection.dart';
import 'package:mime/mime.dart';

part 'asset_store.g.dart';

class AssetStore = _AssetStore with _$AssetStore;

class _AssetStore with Store {
  final DateFormat _defaultYearFormatter = DateFormat('E, MMM dd, yyyy');

  List<UniFiedAsset> assetList = new List.empty();
  Map<String, List<UniFiedAsset>> groupedAssets = new Map();

  final int defaultAssetCount = -1;

  @observable
  AssetSearchProgress assetSearchProgress = AssetSearchProgress.IDLE;

  bool executionInProgress = false;

  AssetSearchCriteria getAssetSearchCriteria() {
    AssetSearchCriteria assetSearchCriteria = AssetSearchCriteria.defaultCriteria();
    assetSearchCriteria.resultPerPage = 500;
    return assetSearchCriteria;
  }

  @action
  Future<void> initStore(int pageNumber) async {
    AssetSearchCriteria searchCriteria = getAssetSearchCriteria();
    searchCriteria.resultPerPage = 100;
    searchCriteria.pageNumber = pageNumber;
    await _processAssetRequest(searchCriteria);
  }

  @action
  Future<void> loadMoreAssets(int pageNumber) async {
    AssetSearchCriteria searchCriteria = getAssetSearchCriteria();
    searchCriteria.pageNumber = pageNumber;
    await _processAssetRequest(searchCriteria);
  }

  @action
  Future<void> refreshStore() async {
    assetSearchProgress = AssetSearchProgress.PROCESSING;
    groupedAssets.clear();
    this.assetList = [];
    await _processAssetRequest(getAssetSearchCriteria());
  }

  Future<void> _processAssetRequest(AssetSearchCriteria searchCriteria) async {
    if (executionInProgress) {
      return;
    }

    executionInProgress = true;

    List<UniFiedAsset> _assetList = [];

    try {
      final newAssets =
          await AssetService.instance.searchOnLocal(searchCriteria);

      if (newAssets.isNotEmpty) {
        for (Asset asset in newAssets) {
          final thumbnail = await ThumbnailService.instance
              .findByIdOnLocal(asset.thumbnailId!);
          asset.thumbnail = thumbnail;

          final metadata =
              await MetadataService.instance.findByIdOnLocal(asset.metadataId!);
          asset.metadata = metadata;
        }

        await _getUnifiedAssetsFromCloudAssets(_assetList, newAssets);
      }

      if (await _getShowDeviceAssetsInfo()) {
        List<String> selectedDeviceFolders =
            await _getShowDeviceAssetsFolderInfo();

        final albums = await PhotoManager.getAssetPathList();
        albums.sort(
            (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

        for (final album in albums) {
          if (selectedDeviceFolders.indexOf(album.id) != -1) {
            await _getUnifiedAssetsFromLocalAssets(_assetList, album);
          }
        }
      }
    } catch (ex) {
      throw Exception(ex.toString());
    }

    assetSearchProgress = AssetSearchProgress.PROCESSING;

    if (this.assetList.isEmpty) {
      this.assetList = [];
    }

    this.assetList.addAll(_assetList);
    this.assetList.sort((UniFiedAsset a, UniFiedAsset b) =>
        b.assetCreationDate.compareTo(a.assetCreationDate));

    for (var asset in assetList) {
      _addUnifiedAssetToGroup(asset.assetCreationDate, asset);
    }

    if (this.assetList.length > 0) {
      this.groupedAssets.keys.forEach((key) {
        this.groupedAssets[key]!.sort((UniFiedAsset a, UniFiedAsset b) =>
            b.assetCreationDate.compareTo(a.assetCreationDate));
      });

      assetSearchProgress = AssetSearchProgress.ASSETS_FOUND;
    } else {
      assetSearchProgress = AssetSearchProgress.IDLE;
    }

    executionInProgress = false;
  }

  _getUnifiedAssetsFromLocalAssets(List<UniFiedAsset> _assetList, AssetPathEntity? album) async {
    
    if (album != null) {
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );

      for (final asset in allAssets) {
        File? assetFile = await asset.file;
        Metadata? metadata = await MetadataRepository.instance.findByNameAndSize(asset.title!, assetFile!.lengthSync());
        
        bool alreadyAdded = false;
        _assetList.forEach((unifiedAsset) {

          if(
            unifiedAsset.assetSource == AssetSource.DEVICE
            && unifiedAsset.assetEntity!.id == asset.id
          ) {
                alreadyAdded = true;
                return;
            }
        });

        if (metadata == null && alreadyAdded == false) {
          final assetDate = asset.createDateTime;

          AppAssetType assetType = asset.type == AssetType.image
              ? AppAssetType.PHOTO
              : AppAssetType.VIDEO;
          _assetList.add(new UniFiedAsset(
              assetType, AssetSource.DEVICE, assetDate,
              assetEntity: asset));
        }
      }
    }
  }

  _getUnifiedAssetsFromCloudAssets(List<UniFiedAsset> _assetList, List<Asset> newAssets) async {
    
    for (final asset in newAssets) {
      final assetDate = asset.metadata!.creationDateTime!;
      asset.thumbnail!.thumbnailFile =
          await AssetService.instance.readThumbnailFile(asset.thumbnail!.name!);

      AppAssetType assetType = asset.assetType == AppAssetType.PHOTO.id
          ? AppAssetType.PHOTO
          : AppAssetType.VIDEO;
      _assetList.add(new UniFiedAsset(
          assetType, AssetSource.CLOUD, assetDate,
          asset: asset));
    }
  }

  _addUnifiedAssetToGroup(DateTime assetDate, UniFiedAsset asset) {
    String key = _defaultYearFormatter.format(assetDate);

    if (groupedAssets.containsKey(key)) {
      List<UniFiedAsset> unifiedAssets = groupedAssets[key]!;

      bool assetAlreadyPresent = false;

      unifiedAssets.forEach((unifiedAsset) {
        if (asset.assetSource == AssetSource.DEVICE &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.assetEntity!.id == asset.assetEntity!.id) {
            assetAlreadyPresent = true;
            return;
          }
        } else if (asset.assetSource == AssetSource.CLOUD &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.asset!.id == asset.asset!.id) {
            assetAlreadyPresent = true;
            return;
          }
        }
      });

      if (!assetAlreadyPresent) {
        unifiedAssets.add(asset);
      }
    } else {
      List<UniFiedAsset> assets = [];
      assets.add(asset);
      groupedAssets.putIfAbsent(key, () => assets);
    }
  }

  Future<bool> _getShowDeviceAssetsInfo() async {
    return await AppConfigService.instance.getFlag(Constants.appConfigShowDeviceAssetsFlag);
  }

  Future<List<String>> _getShowDeviceAssetsFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFolders);

    if (value.configValue != null) {
      return value.configValue!.split(",");
    } else {
      return List.empty();
    }
  }

  bool isAnyItemSelected() {
    return this.assetList.firstWhereOrNull((asset) => asset.selected == true) !=
        null;
  }

  int getSelectedCount() {
    return this.assetList.where((asset) => asset.selected == true).length;
  }

  List<int> getSelectedIndexes() {
    return this
        .assetList
        .where((asset) => asset.selected == true)
        .map((asset) => this.assetList.indexOf(asset))
        .toList();
  }

  List<String> getGroupedMapKeys() {
    List<DateTime> dateTimeKeys = groupedAssets.keys
        .toList()
        .map((key) => _defaultYearFormatter.parse(key))
        .toList();
    dateTimeKeys.sort((DateTime a, DateTime b) => b.compareTo(a));
    return dateTimeKeys
        .map((dateTime) => _defaultYearFormatter.format(dateTime))
        .toList();
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
      final UniFiedAsset unifiedAsset = assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
          Asset asset = unifiedAsset.asset!;
          await AssetService.instance.permanentDownloadAssetById(asset.id!, asset.metadata!.name!, unifiedAsset.assetType);
        }
    }

    return true;
  }

  Future<bool> uploadAssetFilesToServer(List<int> assetIndexes) async {

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = assetList[assetIndex];

      if (unifiedAsset.assetSource == AssetSource.DEVICE) {
          AssetEntity asset = unifiedAsset.assetEntity!;
          File? assetFile  = await asset.file;
          String filePath = assetFile!.path;
          String fileName = filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
          Metadata? metadata = await MetadataRepository.instance.findByNameAndSize(fileName, assetFile.lengthSync());
        
          if (metadata == null) {
            //The asset is not uploaded to server yet;
            await AssetService.instance.save([assetFile]);
          }
        }
    }

    return true;
  }

  _getAssetFile(List<int> assetIndexes) async {
    List<File> assetFiles = [];

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = assetList[assetIndex];

      File? assetFile;

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        assetFile = await AssetService.instance
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

  
}
