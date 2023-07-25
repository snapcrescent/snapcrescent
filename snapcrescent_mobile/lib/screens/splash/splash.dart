import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/models/app_config.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/screens/asset/asset_list.dart';
import 'package:snapcrescent_mobile/screens/settings/settings.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';
import 'package:snapcrescent_mobile/utils/date_utilities.dart';
import 'package:snapcrescent_mobile/utils/permission_utilities.dart';

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
    AppConfig showDeviceAssetsFlagConfig = AppConfig(
        configKey: Constants.appConfigShowDeviceAssetsFlag,
        configValue: true.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(showDeviceAssetsFlagConfig);

    final List<AssetPathEntity> folders = await PhotoManager.getAssetPathList();
      folders.sort((AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

    final List<AssetPathEntity> deviceAssetFolders = [];
    List<String> defaultFolderList = [];
    
    if (Platform.isAndroid) {
        defaultFolderList = Constants.androidDefaultDeviceFolderList;
    } else {
        defaultFolderList = Constants.iosDefaultDeviceFolderList;
    }

    for (var folder in folders) { 

        for (var defaultFolder in defaultFolderList) { 

          if(folder.name.toLowerCase() == defaultFolder.toLowerCase()) {
            deviceAssetFolders.add(folder);
          }
        }
    }

          


      AppConfig showDeviceAssetsFolders = AppConfig(
          configKey: Constants.appConfigShowDeviceAssetsFolders,
          configValue: deviceAssetFolders.map((folder) => folder.id).join(","));

      await AppConfigRepository.instance
          .saveOrUpdateConfig(showDeviceAssetsFolders);

    AppConfig appConfigAutoBackupFrequencyConfig = AppConfig(
        configKey: Constants.appConfigAutoBackupFrequency,
        configValue: Constants.defaultAutoBackupFrequency.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigAutoBackupFrequencyConfig);


    AppConfig appConfigLastSyncTimestampConfig = AppConfig(
        configKey: Constants.appConfigLastSyncActivityTimestamp,
        configValue: DateUtilities().formatDate(Constants.defaultLastSyncActivityTimestamp, DateUtilities.timeStampFormat));

    await AppConfigRepository.instance
        .saveOrUpdateConfig(appConfigLastSyncTimestampConfig);


        
  }

  _setSystemSettings() async {
    AppConfig configLoggedInFlagConfig = AppConfig(
        configKey: Constants.appConfigLoggedInFlag,
        configValue: false.toString());

    await AppConfigRepository.instance
        .saveOrUpdateConfig(configLoggedInFlagConfig);

    AppConfig thumbnailsFolderConfig = AppConfig(
        configKey: Constants.appConfigThumbnailsFolder,
        configValue: 'thumbnails');

    await AppConfigRepository.instance
        .saveOrUpdateConfig(thumbnailsFolderConfig);

    AppConfig tempDownloadsFolderConfig = AppConfig(
        configKey: Constants.appConfigTempDownloadsFolder,
        configValue: 'tempDownload');

    await AppConfigRepository.instance
        .saveOrUpdateConfig(tempDownloadsFolderConfig);

    AppConfig permanentDownloadsFolderConfig = AppConfig(
        configKey: Constants.appConfigPermanentDownloadsFolder,
        configValue: 'SnapCrescent');

    await AppConfigRepository.instance
        .saveOrUpdateConfig(permanentDownloadsFolderConfig);
  }

  Future<bool> _requestPermissions() async {
    await PermissionUtilities().askAllPermissions();
    return true;
  }
}
