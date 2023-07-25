import 'package:snapcrescent_mobile/models/unified_asset.dart';
import 'package:collection/collection.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AssetState {
  AssetState._privateConstructor() : super();

  static final AssetState instance = AssetState._privateConstructor();

  List<UniFiedAsset> assetList = List.empty();
  Map<String, List<UniFiedAsset>> groupedAssets = {};

  List<String> groupedMapKeys = List.empty();

  List<int> getSelectedIndexes() {
    return assetList
        .where((asset) => asset.selected == true)
        .map((asset) => AssetState.instance.assetList.indexOf(asset))
        .toList();
  }

  bool isAnyItemSelected() {
    return AssetState.instance.assetList
            .firstWhereOrNull((asset) => asset.selected == true) !=
        null;
  }

  int getSelectedCount() {
    return AssetState.instance.assetList
        .where((asset) => asset.selected == true)
        .length;
  }

  void prepareGroupedMapKeysList() {

    List<DateTime> dateTimeKeys = groupedAssets.keys
          .toList()
          .map((key) => Constants.defaultYearFormatter.parse(key))
          .toList();

      dateTimeKeys.sort((DateTime a, DateTime b) => b.compareTo(a));
      
      groupedMapKeys = dateTimeKeys.map<String>((dateTime) => Constants.defaultYearFormatter.format(dateTime)).toList();

  }
}
