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
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/constants.dart';
import 'package:collection/collection.dart';

part 'asset_store.g.dart';

abstract class AssetStore = _AssetStore with _$AssetStore;

abstract class _AssetStore with Store {
  _AssetStore() {
    getAssets(false);
  }

  DateTime currentDateTime = DateTime.now();
  final DateFormat currentWeekFormatter = DateFormat('EEEE');
  final DateFormat currentYearFormatter = DateFormat('E, MMM dd');
  final DateFormat defaultYearFormatter = DateFormat('E, MMM dd, yyyy');

  List<UniFiedAsset> assetList = new List.empty();
  Map<String, List<UniFiedAsset>> groupedAssets = new Map();

  @observable
  int assetsCount = 0;

  AssetSearchCriteria getAssetSearchCriteria();

  Iterable<AssetEntity> getFilteredAssets(List<AssetEntity> allAssets);

  @action
  Future<void> getAssets(bool forceReloadFromApi) async {
    
    currentDateTime = DateTime.now();

    groupedAssets.clear();
    this.assetList = [];

    if (forceReloadFromApi) {
      await _getAssetsFromApi();
    } else {
      final newAssets = await AssetService().searchOnLocal(getAssetSearchCriteria());

      if (newAssets.isNotEmpty) {
        for (Asset asset in newAssets) {
          final thumbnail = await ThumbnailService().findByIdOnLocal(asset.thumbnailId!);
          asset.thumbnail = thumbnail;

          final metadata = await MetadataService().findByIdOnLocal(asset.metadataId!);
          asset.metadata = metadata;
        }

        await _addCloudAssetsToList(newAssets);
      } else {
        await _getAssetsFromApi();
      }
    }

    if (await _getShowDeviceAssetsInfo()) {
      List<String> selecteDeviceFolders =
          await _getShowDeviceAssetsFolderInfo();

      final albums = await PhotoManager.getAssetPathList();
      albums.sort(
          (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

       for(final album in albums) {
        if (selecteDeviceFolders.indexOf(album.id) != -1) {
           await _addLocalAssetsToList(album);
           
        }
      }
    }

    if (this.assetList.length > 0) {
      this.assetList.sort((UniFiedAsset a, UniFiedAsset b) =>
          b.assetCreationDate.compareTo(a.assetCreationDate));

      this.groupedAssets.keys.forEach((key) {
        this.groupedAssets[key]!.sort((UniFiedAsset a, UniFiedAsset b) =>
            b.assetCreationDate.compareTo(a.assetCreationDate));
      });
    } 
  }

  Future<void> _getAssetsFromApi() async {
    try {
      final data = await AssetService().searchAndSync(getAssetSearchCriteria());
      await _addCloudAssetsToList(new List<Asset>.from(data));
    } catch (e) {
      ToastService.showError("Unable to reach server");
      print(e);
      return getAssets(false);
    }
  }

  _addLocalAssetsToList(AssetPathEntity? album) async {
    if (album != null) {
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );

      final assets = getFilteredAssets(allAssets);

      for(final asset in assets) {
        //final asset = assets.elementAt(i);
          Metadata metadata = await MetadataRepository.instance.findByNameEndWith(asset.title!);

          if(metadata.id == null) {
            final assetDate = asset.createDateTime;
              _addUnifiedAssetToGroup(
                  assetDate, _getUnifiedAssetFromDeviceAsset(asset, assetDate));
          }   
      }
    }
  }

  _addCloudAssetsToList(List<Asset> newAssets) async {
    for(final asset in newAssets) {  
      final assetDate = asset.metadata!.creationDatetime!;

      asset.thumbnail!.thumbnailFile = await AssetService().readThumbnailFile(asset.thumbnail!.name!);

      _addUnifiedAssetToGroup(
          assetDate, _getUnifiedAssetFromCloudAsset(asset, assetDate));
    }
  }

  _addUnifiedAssetToGroup(DateTime assetDate, UniFiedAsset asset) {
    String key = defaultYearFormatter.format(assetDate);

    if (groupedAssets.containsKey(key)) {
      groupedAssets[key]!.add(asset);
    } else {
      List<UniFiedAsset> assets = [];
      assets.add(asset);
      groupedAssets.putIfAbsent(key, () => assets);
    }

    this.assetList.add(asset);
    this.assetsCount = this.assetList.length;
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
        .map((key) => defaultYearFormatter.parse(key))
        .toList();
    dateTimeKeys.sort((DateTime a, DateTime b) => b.compareTo(a));
    return dateTimeKeys
        .map((datetime) => defaultYearFormatter.format(datetime))
        .toList();
  }

  clearStore() {
    assetList = new List.empty();
    groupedAssets = new Map();
  }
}