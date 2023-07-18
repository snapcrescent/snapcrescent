import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/screens/asset/asset_list.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/services/toast_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _SplashScreenView());
  }
}

class _SplashScreenView extends StatefulWidget {
  @override
  _SplashScreenViewState createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<_SplashScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDefaultAppConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }

  _setDefaultAppConfig() async {

    bool allPermissionsApproved = await _requestPermissions();

    AppConfig firstBootConfig = await AppConfigRepository.instance
        .findByKey(Constants.appConfigFirstBootFlag);

    // This is first boot of application
    if (firstBootConfig.configValue == null) {
      firstBootConfig.configKey = Constants.appConfigFirstBootFlag;
      firstBootConfig.configValue = false.toString();

      await AppConfigRepository.instance.saveOrUpdateConfig(firstBootConfig);

      if(allPermissionsApproved) {
        await _setDefaultSettings();
      }
      
      await _setSystemSettings();
    }

    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => AssetListScreen(),
      ),
      (route) => false, //if you want to disable back feature set to false
    );

    if (!allPermissionsApproved) {
      Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SettingsScreen()));
    }
  }

  _setDefaultSettings() async {
    AppConfig showDeviceAssetsFlagConfig = new AppConfig(
        configKey: Constants.appConfigShowDeviceAssetsFlag,
        configValue: true.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(showDeviceAssetsFlagConfig);

    final List<AssetPathEntity> folders =
          await PhotoManager.getAssetPathList();
      folders.sort(
          (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

      AppConfig showDeviceAssetsFolders = new AppConfig(
          configKey: Constants.appConfigShowDeviceAssetsFolders,
          configValue: folders.map((folder) => folder.id).join(","));

      await AppConfigRepository.instance
          .saveOrUpdateConfig(showDeviceAssetsFolders);

    AppConfig appConfigAutoBackupFrequencyConfig = new AppConfig(
        configKey: Constants.appConfigAutoBackupFrequency,
        configValue: Constants.defaultAutoBackupFrequency.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigAutoBackupFrequencyConfig);


    AppConfig appConfigLastSyncTimestampConfig = new AppConfig(
        configKey: Constants.appConfigLastSyncActivityTimestamp,
        configValue: DateUtilities().formatDate(DateTime(2000, 1, 1, 0, 0, 0, 0, 0), DateUtilities.timeStampFormat));

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigLastSyncTimestampConfig);


        
  }

  _setSystemSettings() async {
    AppConfig configLoggedInFlagConfig = new AppConfig(
        configKey: Constants.appConfigLoggedInFlag,
        configValue: false.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(configLoggedInFlagConfig);

    AppConfig thumbnailsFolderConfig = new AppConfig(
        configKey: Constants.appConfigThumbnailsFolder,
        configValue: 'thumbnails');

    await AppConfigRepository.instance
        .saveOrUpdateConfig(thumbnailsFolderConfig);

    AppConfig tempDownloadsFolderConfig = new AppConfig(
        configKey: Constants.appConfigTempDownloadsFolder,
        configValue: 'tempDownload');

    await AppConfigRepository.instance
        .saveOrUpdateConfig(tempDownloadsFolderConfig);

    AppConfig permanentDownloadsFolderConfig = new AppConfig(
        configKey: Constants.appConfigPermanentDownloadsFolder,
        configValue: 'SnapCrescent');

    await AppConfigRepository.instance
        .saveOrUpdateConfig(permanentDownloadsFolderConfig);
  }

  Future<bool> _requestPermissions() async {
    bool allApproved = true;

    if (allApproved) {
      allApproved = await _requestFolderPermissions();
    }

    return allApproved;
  }

  Future<bool> _requestFolderPermissions() async {
    bool approved = false;

    final PermissionState _ps = await PhotoManager.requestPermissionExtend();

    if (_ps.isAuth) {
      approved = true;
    } else {
      ToastService.showError('Permission to device folders denied!');
    }

    return approved;
  }
}
