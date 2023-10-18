import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/asset/asset.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class UniFiedAsset  {

  AssetSource assetSource;
  DateTime assetCreationDate;
  bool selected = false;
  AppAssetType assetType;
  Asset? asset;
  AssetEntity? assetEntity;
  int duration;
  int? width;
  int? height;

  UniFiedAsset(
        this.assetType,
        this.assetSource,
        this.assetCreationDate,
        this.duration,
        {
          this.asset,
          this.assetEntity,
          this.width,
          this.height,
        }
      );

}
