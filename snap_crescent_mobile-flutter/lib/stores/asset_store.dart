import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/models/asset_search_criteria.dart';
import 'package:snap_crescent/services/asset_service.dart';
import 'package:snap_crescent/services/metadata_service.dart';
import 'package:snap_crescent/services/thumbnail_service.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/common_utils.dart';
import 'package:snap_crescent/utils/constants.dart';

part 'asset_store.g.dart';

abstract class AssetStore = _AssetStore with _$AssetStore;

abstract class _AssetStore with Store {
  _AssetStore() {
    getAssets(false);
  }

  List<Asset> assetList = new List.empty();
  Map<String, List<Asset>> groupedAssets = new Map();

  @observable
  AssetSearchProgress assetsSearchProgress = AssetSearchProgress.SEARCHING;

  AssetSearchCriteria getAssetSearchCriteria();

  @action
  Future<void> getAssets(bool forceReloadFromApi) async {
    _updateAssetList(new List.empty());
    
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

        _updateAssetList(newAssets);
      } else {
        await getAssetsFromApi();
      }
    }
  }

  Future<void> getAssetsFromApi() async {
    try {
      final data = await AssetService().searchAndSync(getAssetSearchCriteria());
      _updateAssetList(new List<Asset>.from(data));
    } catch (e) {
      ToastService.showError("Unable to reach server");
      print(e);
      return getAssets(false);
    }
  }

  Asset getAssetsAtIndex(int assetIndex) {
    return assetList[assetIndex];
  }

  _updateAssetList(List<Asset> newAssets) {
    if (newAssets.length > 0) {
      this.assetList = newAssets;

      groupedAssets.clear();
      final currentDateTime = DateTime.now();
      final DateFormat currentWeekFormatter = DateFormat('EEEE');
      final DateFormat currentYearFormatter = DateFormat('E, MMM dd');
      final DateFormat defaultYearFormatter = DateFormat('E, MMM dd, yyyy');
      assetList.forEach((asset) {
        final assetDate = asset.metadata!.creationDatetime!;
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
          List<Asset> assets = [];
          assets.add(asset);
          groupedAssets.putIfAbsent(key, () => assets);
        }
      });

    assetsSearchProgress = AssetSearchProgress.ASSETS_FOUND;  
    } else{
      assetsSearchProgress = AssetSearchProgress.ASSETS_NOT_FOUND;  
    }
  }
}
