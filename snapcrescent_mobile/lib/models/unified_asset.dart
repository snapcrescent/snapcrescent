import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/asset.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class UniFiedAsset  {

  AssetSource assetSource;
  DateTime assetCreationDate;
  bool selected = false;
  AppAssetType assetType;
  Asset? asset;
  AssetEntity? assetEntity;

  UniFiedAsset(
        this.assetType,
        this.assetSource,
        this.assetCreationDate,
        {
          this.asset,
          this.assetEntity,
        }
      );

}