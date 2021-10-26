import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/models/unified_asset.dart';
import 'package:snap_crescent/resository/app_config_resository.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/metadata_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/common_utils.dart';
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
  AssetSearchProgress assetsSearchProgress = AssetSearchProgress.IDLE;

  AssetSearchCriteria getAssetSearchCriteria();

  Iterable<AssetEntity> getFilteredAssets(List<AssetEntity> allAssets);

  @action
  Future<void> getAssets(bool forceReloadFromApi) async {
    assetsSearchProgress = AssetSearchProgress.SEARCHING;
    
    currentDateTime = DateTime.now();

    groupedAssets.clear();
    this.assetList = [];
    
    
    if(await _getShowDeviceAssetsInfo()) {

      List<String> selecteDeviceFolders = await _getShowDeviceAssetsFolderInfo();


      final albums = await PhotoManager.getAssetPathList();
      albums.sort((AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

      albums.forEach((album) {
        if(selecteDeviceFolders.indexOf(album.id) != -1) {
          _addLocalAssetsToList(album);
        }
      });  
    }
    
    if (forceReloadFromApi) {
      await getAssetsFromApi();
    } else {
      final newAssets =
          await AssetService().searchOnLocal(getAssetSearchCriteria());

      if (newAssets.isNotEmpty) {
        for (Asset asset in newAssets) {
          final thumbnail =
              await ThumbnailService().findByIdOnLocal(asset.thumbnailId!);
          asset.thumbnail = thumbnail;

          final metadata =
              await MetadataService().findByIdOnLocal(asset.metadataId!);
          asset.metadata = metadata;
        }

        _addCloudAssetsToList(newAssets);
      } else {
        await getAssetsFromApi();
      }
    }


    if (this.assetList.length > 0) {
      assetsSearchProgress = AssetSearchProgress.ASSETS_FOUND;
      this.assetList.sort((UniFiedAsset a, UniFiedAsset b) => b.assetCreationDate.compareTo(a.assetCreationDate));

      this.groupedAssets.keys.forEach((key) {
        this.groupedAssets[key]!.sort((UniFiedAsset a, UniFiedAsset b) => b.assetCreationDate.compareTo(a.assetCreationDate));
      });
      
    } else {
      assetsSearchProgress = AssetSearchProgress.ASSETS_NOT_FOUND;
    }
  }

  Future<void> getAssetsFromApi() async {
    try {
      final data = await AssetService().searchAndSync(getAssetSearchCriteria());
      _addCloudAssetsToList(new List<Asset>.from(data));
    } catch (e) {
      ToastService.showError("Unable to reach server");
      print(e);
      return getAssets(false);
    }
  }

  UniFiedAsset getAssetAtIndex(int assetIndex) {
    return assetList[assetIndex];
  }

  _addLocalAssetsToList(AssetPathEntity? album) async {
    if (album != null) {
      final allAssets = await album.getAssetListRange(
        start: 0, // start at index 0
        end: 100000, // end at a very big index (to get all the assets)
      );

      final assets = getFilteredAssets(allAssets);

      assets.forEach((asset) {
        final assetDate = asset.createDateTime;
        _addUnifiedAssetToGroup(assetDate, _getUnifiedAssetFromDeviceAsset(asset,assetDate));
      });
  
    }
  }

  _addCloudAssetsToList(List<Asset> newAssets) {

      newAssets.forEach((asset) {
        final assetDate = asset.metadata!.creationDatetime!;
        _addUnifiedAssetToGroup(assetDate, _getUnifiedAssetFromCloudAsset(asset,assetDate));
      });
  }

  _addUnifiedAssetToGroup(DateTime assetDate, UniFiedAsset asset) {

    String key;
        if (currentDateTime.year == assetDate.year) {
          if (CommonUtils().weekNumber(currentDateTime) ==
              CommonUtils().weekNumber(assetDate)) {
            if (currentDateTime.day == assetDate.day) {
              key = 'Today';
            } else {
              key = currentWeekFormatter.format(assetDate);
            }
          } else {
            key = currentYearFormatter.format(assetDate);
          }
        } else {
          key = defaultYearFormatter.format(assetDate);
        }

        if (groupedAssets.containsKey(key)) {
          groupedAssets[key]!.add(asset);
        } else {
          List<UniFiedAsset> assets = [];
          assets.add(asset);
          groupedAssets.putIfAbsent(key, () => assets);
        }

        this.assetList.add(asset);

  }

  _getUnifiedAssetFromDeviceAsset(AssetEntity deviceAsset, DateTime assetDate) {
    return new UniFiedAsset(AssetSource.DEVICE, assetDate, assetEntity: deviceAsset);
  }

  _getUnifiedAssetFromCloudAsset(Asset cloudAsset, DateTime assetDate) {
    return new UniFiedAsset(AssetSource.CLOUD,assetDate,asset: cloudAsset);
  } 

  Future<bool> _getShowDeviceAssetsInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFlag);

    if (value.configValue != null) {
      return value.configValue == 'true' ? true : false;
    } else {
      return false;
    }
  }

  Future<List<String>> _getShowDeviceAssetsFolderInfo() async {
    AppConfig value = await AppConfigResository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFolders);

    if (value.configValue != null) {
      return value.configValue!.split(",");
    } else {
      return List.empty();
    }
  }

  bool isAnyItemSelected() {
    return this.assetList.firstWhereOrNull((asset) => asset.selected == true) != null;
  }

  int getSelectedCount() {
    return this.assetList.where((asset) => asset.selected == true).length;
  }

}
