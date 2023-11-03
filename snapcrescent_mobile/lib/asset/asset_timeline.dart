import 'package:snapcrescent_mobile/asset/unified_asset.dart';

class AssetTimeline  {

  DateTime creationDateTime;
  int count;
  List<UniFiedAsset>? unifiedAssets;

  AssetTimeline(
        this.creationDateTime,
        this.count,
      );


 factory AssetTimeline.fromMap(Map<String, dynamic> map) {
    return AssetTimeline(
        DateTime.fromMillisecondsSinceEpoch(map['CREATION_DATE_TIME']*1000),
        map['COUNT'],
        );
  }
}

class AssetYearlyTimeline  {

  DateTime creationDateTime;
  int count;
  List<AssetTimeline> assetTimelines = [];

  AssetYearlyTimeline(
        this.creationDateTime,
        this.count,
      );
}
