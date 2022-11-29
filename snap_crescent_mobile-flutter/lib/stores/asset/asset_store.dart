import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
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

abstract class AssetStore = _AssetStore with _$AssetStore;

abstract class _AssetStore with Store {
  final DateFormat _defaultYearFormatter = DateFormat('E, MMM dd, yyyy');

  List<UniFiedAsset> assetList = new List.empty();
  Map<String, List<UniFiedAsset>> groupedAssets = new Map();

  final int defaultAssetCount = -1;

  @observable
  AssetSearchProgress assetSearchProgress = AssetSearchProgress.IDLE;

  AssetSearchCriteria getAssetSearchCriteria();
  Iterable<AssetEntity> getFilteredAssets(List<AssetEntity> allAssets);

  bool executionInProgress = false;

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

        await _addCloudAssetsToList(newAssets);
      }

      if (await _getShowDeviceAssetsInfo()) {
        List<String> selectedDeviceFolders =
            await _getShowDeviceAssetsFolderInfo();

        final albums = await PhotoManager.getAssetPathList();
        albums.sort(
            (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

        for (final album in albums) {
          if (selectedDeviceFolders.indexOf(album.id) != -1) {
            await _addLocalAssetsToList(album);
          }
        }
      }
    } catch (ex) {
      throw Exception(ex.toString());
    }

    assetSearchProgress = AssetSearchProgress.PROCESSING;

    if (this.assetList.length > 0) {
      this.assetList.sort((UniFiedAsset a, UniFiedAsset b) =>
          b.assetCreationDate.compareTo(a.assetCreationDate));

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

  _addLocalAssetsToList(AssetPathEntity? album) async {
    if (album != null) {
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );

      final assets = getFilteredAssets(allAssets);

      for (final asset in assets) {
        Metadata metadata =
            await MetadataRepository.instance.findByNameEndWith(asset.title!);

        if (metadata.id == null) {
          final assetDate = asset.createDateTime;
          _addUnifiedAssetToGroup(
              assetDate, _getUnifiedAssetFromDeviceAsset(asset, assetDate));
        }
      }
    }
  }

  _addCloudAssetsToList(List<Asset> newAssets) async {
    for (final asset in newAssets) {
      final assetDate = asset.metadata!.creationDateTime!;
      _addUnifiedAssetToGroup(
          assetDate, _getUnifiedAssetFromCloudAsset(asset, assetDate));
      asset.thumbnail!.thumbnailFile =
          await AssetService.instance.readThumbnailFile(asset.thumbnail!.name!);
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

    if (this.assetList.isEmpty) {
      this.assetList = [];
    }
    this.assetList.add(asset);
  }

  _getUnifiedAssetFromDeviceAsset(AssetEntity deviceAsset, DateTime assetDate) {
    return new UniFiedAsset(AssetSource.DEVICE, assetDate,
        assetEntity: deviceAsset);
  }

  _getUnifiedAssetFromCloudAsset(Asset cloudAsset, DateTime assetDate) {
    return new UniFiedAsset(AssetSource.CLOUD, assetDate, asset: cloudAsset);
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
}
