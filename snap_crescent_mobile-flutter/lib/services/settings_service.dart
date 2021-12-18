import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/models/sync_info.dart';
import 'package:snap_crescent/models/user_login_response.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/services/login_service.dart';
import 'package:snap_crescent/services/sync_info_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class SettingsService {

  SettingsService._privateConstructor():super();
  static final SettingsService instance = SettingsService._privateConstructor();

  updateFlag(String flag, bool value) async {
    AppConfig appConfig = new AppConfig(
        configkey: flag,
        configValue: value.toString());

    await AppConfigRepository.instance.saveOrUpdateConfig(appConfig);
  }

  getFlag(String flag ) async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(flag);

    bool _autoBackup = false;
    if (value.configValue != null) {
      _autoBackup = value.configValue == 'true' ? true : false;
    }

    return _autoBackup;
  }

  Future<String> getAutoBackupFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance.findByKey(Constants.appConfigAutoBackupFolders);

    String _autoBackupFolders = "None"; 
    if (value.configValue != null) {
      List<String> autoBackupFolderIdList = value.configValue!.split(",");

      final List<AssetPathEntity> assets =
          await PhotoManager.getAssetPathList();
      List<String> autoBackupFolderNameList = assets
          .where((asset) => autoBackupFolderIdList.indexOf(asset.id) > -1)
          .map((asset) => asset.name)
          .toList();

      if (autoBackupFolderNameList.length == assets.length) {
        _autoBackupFolders = "All";
      } else {
        _autoBackupFolders = autoBackupFolderNameList.join(", ");
      }
    }

    return _autoBackupFolders;
  }

  Future<String> getShowDeviceAssetsFolderInfo() async {
    AppConfig value = await AppConfigRepository.instance
        .findByKey(Constants.appConfigShowDeviceAssetsFolders);

    String _showDeviceAssetsFolders = "None";     

    if (value.configValue != null) {
      List<String> showDeviceAssetsFolderIdList = value.configValue!.split(",");

      final List<AssetPathEntity> assets =
          await PhotoManager.getAssetPathList();
      List<String> showDeviceAssetsFolderNameList = assets
          .where((asset) => showDeviceAssetsFolderIdList.indexOf(asset.id) > -1)
          .map((asset) => asset.name)
          .toList();

      if (showDeviceAssetsFolderNameList.length == assets.length) {
        _showDeviceAssetsFolders = "All";
      } else {
        _showDeviceAssetsFolders = showDeviceAssetsFolderNameList.join(", ");
      }
    }

    return _showDeviceAssetsFolders;
  }



  Future<String> getLastSyncInfo() async {
    List<SyncInfo> localSyncInfoList = await SyncInfoService.instance.searchOnLocal();

    String _lastSyncDate = "Never";
    if (localSyncInfoList.isEmpty == false) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss ');
      _lastSyncDate =
          formatter.format(localSyncInfoList.last.lastModifiedDatetime!);
    } 

    return _lastSyncDate;
  }

  Future<List<String>> getAccountInformation() async {

    AppConfig appConfigServerURL = await AppConfigRepository.instance.findByKey(Constants.appConfigServerURL);

    List<String> result = [];

    if (appConfigServerURL.configValue != null) {
      result.add(appConfigServerURL.configValue!);
    } else {
      result.add("http://192.168.0.16:8080");
    }

    AppConfig appConfigServerUserName = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerUserName);

    if (appConfigServerUserName.configValue != null) {
      result.add(appConfigServerUserName.configValue!);
    } else {
      result.add("admin");
    }

    AppConfig appConfigServerPassword = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerPassword);

    if (appConfigServerPassword.configValue != null) {
      result.add(appConfigServerPassword.configValue!);
    } else {
      result.add("password");
    }

    return result;
    
  }

  Future<UserLoginResponse> saveAccountInformation(String serverUrl, String username, String password) async {

      AppConfig serverUrlConfig = new AppConfig(
          configkey: Constants.appConfigServerURL,
          configValue: serverUrl);

      AppConfig serverUserNameConfig = new AppConfig(
          configkey: Constants.appConfigServerUserName,
          configValue: username);

      AppConfig serverPasswordConfig = new AppConfig(
          configkey: Constants.appConfigServerPassword,
          configValue: password);

      await AppConfigRepository.instance.saveOrUpdateConfig(serverUrlConfig);
      await AppConfigRepository.instance.saveOrUpdateConfig(serverUserNameConfig);
      await AppConfigRepository.instance.saveOrUpdateConfig(serverPasswordConfig);

      UserLoginResponse userLoginResponse = await LoginService.instance.login();

      return userLoginResponse;


  }

}