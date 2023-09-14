import 'package:snapcrescent_mobile/models/unified_asset.dart';
import 'package:collection/collection.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AssetState {
  static final AssetState _singleton = AssetState._internal();

  factory AssetState() {
    return _singleton;
  }

  AssetState._internal();

  List<UniFiedAsset> assetList = [];
  Map<String, List<UniFiedAsset>> groupedAssets = {};

  List<String> groupedMapKeys = List.empty();

  List<int> getSelectedIndexes() {
    return assetList
        .where((asset) => asset.selected == true)
        .map((asset) => assetList.indexOf(asset))
        .toList();
  }

  bool isAnyItemSelected() {
    return assetList.firstWhereOrNull((asset) => asset.selected == true) !=
        null;
  }

  int getSelectedCount() {
    return assetList.where((asset) => asset.selected == true).length;
  }

  void addAsset(UniFiedAsset asset) {
    String key = Constants.defaultYearFormatter.format(asset.assetCreationDate);

    if (groupedAssets.containsKey(key)) {
      List<UniFiedAsset> unifiedAssets = groupedAssets[key]!;

      bool assetAlreadyPresent = false;

      for (var unifiedAsset in unifiedAssets) {
        if (asset.assetSource == AssetSource.DEVICE &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.assetEntity!.id == asset.assetEntity!.id) {
            assetAlreadyPresent = true;
            continue;
          }
        } else if (asset.assetSource == AssetSource.CLOUD &&
            asset.assetSource == unifiedAsset.assetSource) {
          if (unifiedAsset.asset!.id == asset.asset!.id) {
            assetAlreadyPresent = true;
            continue;
          }
        }
      }

      if (!assetAlreadyPresent) {
        unifiedAssets.add(asset);
        assetList.add(asset);
      }
    } else {
      List<UniFiedAsset> assets = [];
      assets.add(asset);
      assetList.add(asset);
      groupedAssets.putIfAbsent(key, () => assets);
    }
  }

  void prepareGroupedMapKeysList() {
    List<DateTime> dateTimeKeys = groupedAssets.keys
        .toList()
        .map((key) => Constants.defaultYearFormatter.parse(key))
        .toList();

    dateTimeKeys.sort((DateTime a, DateTime b) => b.compareTo(a));

    groupedMapKeys = dateTimeKeys
        .map<String>(
            (dateTime) => Constants.defaultYearFormatter.format(dateTime))
        .toList();
  }
}
