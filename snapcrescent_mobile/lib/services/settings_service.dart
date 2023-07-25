import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/models/user/user_login_response.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/services/base_service.dart';
import 'package:snapcrescent_mobile/services/login_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class SettingsService extends BaseService {
  SettingsService._privateConstructor() : super();
  static final SettingsService instance = SettingsService._privateConstructor();

  Future<String> getAutoBackupFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigAutoBackupFolders);

    String autoBackupFolders = "";
    if (value.configValue != null) {
      List<String> autoBackupFolderIdList = value.configValue!.split(",");

      final List<AssetPathEntity> assets =
          await PhotoManager.getAssetPathList();
      List<String> autoBackupFolderNameList = assets
          .where((asset) => autoBackupFolderIdList.contains(asset.id))
          .map((asset) => asset.name)
          .toList();

      if (autoBackupFolderNameList.length == assets.length) {
        autoBackupFolders = "All";
      } else if (autoBackupFolderNameList.length < assets.length) {
        autoBackupFolders = autoBackupFolderNameList.join(", ");
      } 
    }

    return autoBackupFolders;
  }

  Future<String> getShowDeviceAssetsFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFolders);

    String showDeviceAssetsFolders = "";

    if (value.configValue != null) {
      List<String> showDeviceAssetsFolderIdList = value.configValue!.split(",");

      final List<AssetPathEntity> assets =
          await PhotoManager.getAssetPathList();
      List<String> showDeviceAssetsFolderNameList = assets
          .where((asset) => showDeviceAssetsFolderIdList.contains(asset.id))
          .map((asset) => asset.name)
          .toList();

      if (showDeviceAssetsFolderNameList.length == assets.length) {
        showDeviceAssetsFolders = "All";
      } else {
        showDeviceAssetsFolders = showDeviceAssetsFolderNameList.join(", ");
      }
    }

    return showDeviceAssetsFolders;
  }

  Future<String> getAutoBackupFrequencyInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigAutoBackupFrequency);

    String autoBackupFrequency = "";

    if (value.configValue != null) {
      autoBackupFrequency = value.configValue!;
    }

    return autoBackupFrequency;
  }

  AutoBackupFrequencyType getReadableOfAutoBackupFrequency(String autoBackupFrequencyString) {
    AutoBackupFrequencyType autoBackupFrequencyType = AutoBackupFrequencyType.HOURS;

    if (autoBackupFrequencyString.isNotEmpty) {
      int autoBackupFrequency = int.parse(autoBackupFrequencyString);

      if (autoBackupFrequency < 60 * 24) {
        autoBackupFrequencyType = AutoBackupFrequencyType.HOURS;
      } else {
        autoBackupFrequencyType = AutoBackupFrequencyType.DAYS;
      }
    }

    return autoBackupFrequencyType;
  }

  Future<List<String>> getAccountInformation() async {
    AppConfig appConfigServerURL = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerURL);

    List<String> result = [];

    if (appConfigServerURL.configValue != null) {
      result.add(appConfigServerURL.configValue!);
    } else {
      result.add("https://");
    }

    AppConfig appConfigServerUserName = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerUserName);

    if (appConfigServerUserName.configValue != null) {
      result.add(appConfigServerUserName.configValue!);
    } else {
      result.add("");
    }

    AppConfig appConfigServerPassword = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerPassword);

    if (appConfigServerPassword.configValue != null) {
      result.add(appConfigServerPassword.configValue!);
    } else {
      result.add("");
    }

    return result;
  }

  Future<UserLoginResponse?> saveAccountInformation(
      String serverUrl, String username, String password) async {
    AppConfig serverUrlConfig = AppConfig(
        configKey: Constants.appConfigServerURL, configValue: serverUrl);

    AppConfig serverUserNameConfig = AppConfig(
        configKey: Constants.appConfigServerUserName, configValue: username);

    AppConfig serverPasswordConfig = AppConfig(
        configKey: Constants.appConfigServerPassword, configValue: password);

    await AppConfigRepository.instance.saveOrUpdateConfig(serverUrlConfig);
    await AppConfigRepository.instance.saveOrUpdateConfig(serverUserNameConfig);
    await AppConfigRepository.instance.saveOrUpdateConfig(serverPasswordConfig);

    UserLoginResponse? userLoginResponse = await LoginService.instance.login();

    return userLoginResponse;
  }
}
