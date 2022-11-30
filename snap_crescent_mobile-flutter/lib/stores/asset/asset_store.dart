import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/metadata.dart';
import 'package:snap_crescent/models/unified_asset.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/repository/metadata_repository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/metadata_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:collection/collection.dart';

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
  Future<void> loadMoreAssets(int pageNumber) async {
    AssetSearchCriteria searchCriteria = getAssetSearchCriteria();
    searchCriteria.pageNumber = pageNumber;
    await _processAssetRequest(searchCriteria);
  }

  @action
  Future<void> getAssets(bool clearPreloadedAssets) async {
    if (clearPreloadedAssets) {
      groupedAssets.clear();
      this.assetList = [];
    }
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

        _assetList.addAll(await _getUnifiedAssetsFromCloudAssets(newAssets));
      }

      if (await _getShowDeviceAssetsInfo()) {
        List<String> selectedDeviceFolders =
            await _getShowDeviceAssetsFolderInfo();

        final albums = await PhotoManager.getAssetPathList();
        albums.sort(
            (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

        for (final album in albums) {
          if (selectedDeviceFolders.indexOf(album.id) != -1) {
            _assetList.addAll(await _getUnifiedAssetsFromLocalAssets(album));
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
    this.assetList.sort((UniFiedAsset a, UniFiedAsset b) => b.assetCreationDate.compareTo(a.assetCreationDate));

    for (var asset in assetList) {
       _addUnifiedAssetToGroup(asset.assetCreationDate,asset);
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

  _getUnifiedAssetsFromLocalAssets(AssetPathEntity? album) async {

    List<UniFiedAsset> uniFiedAssets = [];

    if (album != null) {
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );

      for (final asset in allAssets) {
        Metadata metadata =
            await MetadataRepository.instance.findByNameEndWith(asset.title!);

        if (metadata.id == null) {
          final assetDate = asset.createDateTime;

          AppAssetType assetType = asset.type == AssetType.image ? AppAssetType.PHOTO : AppAssetType.VIDEO;
          uniFiedAssets.add(new UniFiedAsset(assetType, AssetSource.DEVICE, assetDate,assetEntity: asset));
          
        }
      }
    }

    return uniFiedAssets;
  }

 _getUnifiedAssetsFromCloudAssets(List<Asset> newAssets) async {

    List<UniFiedAsset> uniFiedAssets = [];
    for (final asset in newAssets) {
      final assetDate = asset.metadata!.creationDateTime!;
      asset.thumbnail!.thumbnailFile = await AssetService.instance.readThumbnailFile(asset.thumbnail!.name!);

      AppAssetType assetType = asset.assetType == AppAssetType.PHOTO.id ?  AppAssetType.PHOTO : AppAssetType.VIDEO;
      uniFiedAssets.add(new UniFiedAsset(assetType, AssetSource.CLOUD, assetDate, asset: asset));
    }

    return uniFiedAssets;
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
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFlag);

    if (value.configValue != null) {
      return value.configValue == 'true' ? true : false;
    } else {
      return false;
    }
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
    return this.assetList.where((asset) => asset.selected == true).map((asset) => this.assetList.indexOf(asset)).toList();
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

  getAssetFileForSharing(List<int> assetIndexes) async {
    List<XFile> xFiles = [];
    List<File> assetFiles = await _getAssetFile(assetIndexes);

    for (var assetFile in assetFiles) {
      xFiles.add(XFile(assetFile.path));
    }

    return xFiles;
  }

  _getAssetFile(List<int> assetIndexes) async {

    List<File> assetFiles = [];

    for (var assetIndex in assetIndexes) {
      final UniFiedAsset unifiedAsset = assetList[assetIndex];

      File? assetFile;

      if (unifiedAsset.assetSource == AssetSource.CLOUD) {
        Asset asset = unifiedAsset.asset!;
        assetFile = await AssetService.instance.downloadAssetById(asset.id!, asset.metadata!.name!);
      } else {
        AssetEntity asset = unifiedAsset.assetEntity!;
        assetFile = await asset.file;
      }

      if(assetFile != null) {
        assetFiles.add(assetFile);
      }
      
    }

    return assetFiles;
  }
}
