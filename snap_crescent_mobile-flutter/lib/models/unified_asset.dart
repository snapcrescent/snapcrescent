import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/asset.dart';
import 'package:snap_crescent/utils/constants.dart';

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
