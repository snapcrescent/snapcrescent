import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/services/app_config_service.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class SettingsService extends BaseService {
  static final SettingsService _singleton = SettingsService._internal();

  factory SettingsService() {
    return _singleton;
  }

  SettingsService._internal();

  Future<String> getFolderInfo(String appConfigKey) async {
    List<String> autoBackupFolderIdList =
        await AppConfigService().getStringListConfig(appConfigKey, ",");
    return _getCombinedFolderString(autoBackupFolderIdList);
  }

  Future<String> _getCombinedFolderString(
      List<String> assetsFolderIdList) async {
    String deviceAssetsFolders = "";

    final List<AssetPathEntity> assets = await PhotoManager.getAssetPathList();
    List<String> deviceAssetsFolderNameList = assets
        .where((asset) => assetsFolderIdList.contains(asset.id))
        .map((asset) => asset.name)
        .toList();

    if (deviceAssetsFolderNameList.length == assets.length) {
      deviceAssetsFolders = "All";
    } else {
      deviceAssetsFolders = deviceAssetsFolderNameList.join(", ");
    }

    return deviceAssetsFolders;
  }

  AutoBackupFrequencyType getReadableOfAutoBackupFrequency(
      String autoBackupFrequencyString) {
    AutoBackupFrequencyType autoBackupFrequencyType =
        AutoBackupFrequencyType.DAYS;

    if (autoBackupFrequencyString.isNotEmpty) {
      int autoBackupFrequency = int.parse(autoBackupFrequencyString);

      if (autoBackupFrequency < 60 * 24 * 7) {
        autoBackupFrequencyType = AutoBackupFrequencyType.DAYS;
      } else {
        autoBackupFrequencyType = AutoBackupFrequencyType.WEEKS;
      }
    }

    return autoBackupFrequencyType;
  }
}
