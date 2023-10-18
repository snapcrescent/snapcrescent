import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/appConfig/app_config_service.dart';
import 'package:snapcrescent_mobile/asset/screens/asset_list.dart';
import 'package:snapcrescent_mobile/services/global_service.dart';
import 'package:snapcrescent_mobile/settings/screens/settings_list.dart';
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

    bool firstBoot = await AppConfigService().getFlag(Constants.appConfigFirstBootFlag, true);

    // This is first boot of application
    if (firstBoot == true) {
      await await AppConfigService().updateFlag(Constants.appConfigFirstBootFlag, false);

      if(allPermissionsApproved) {
        await _setDefaultSettings();
      }
      
      await _setSystemSettings();
    }

    _goToDefaultLandingScreen();
    

    if (!allPermissionsApproved) {
      _goToFallbackScreen();
    }
  }

  _setDefaultSettings() async {
    await AppConfigService().updateFlag(Constants.appConfigShowDeviceAssetsFlag, true);
    
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

    await AppConfigService().updateConfig(Constants.appConfigShowDeviceAssetsFolders, deviceAssetFolders.map((folder) => folder.id).join(","));
    await AppConfigService().updateIntConfig(Constants.appConfigAutoBackupFrequency, Constants.defaultAutoBackupFrequency);
    await AppConfigService().updateDateConfig(Constants.appConfigLastSyncActivityTimestamp, Constants.defaultLastSyncActivityTimestamp, DateUtilities.timeStampFormat);    
  }

  _setSystemSettings() async {
    await AppConfigService().updateFlag(Constants.appConfigLoggedInFlag, false);
    await AppConfigService().updateConfig(Constants.appConfigThumbnailsFolder, 'thumbnails');
    await AppConfigService().updateConfig(Constants.appConfigTempDownloadsFolder, 'tempDownload');
    await AppConfigService().updateConfig(Constants.appConfigPermanentDownloadsFolder, 'SnapCrescent');
  }

  Future<bool> _requestPermissions() async {
    await PermissionUtilities().checkAndAskForPhotosPermission();
    return true;
  }

  _goToDefaultLandingScreen() {
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => AssetListScreen(),
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }

  _goToFallbackScreen() {
    Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SettingsListScreen()));
  }
}
