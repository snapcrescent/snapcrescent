import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/services/toast_service.dart';
import 'package:snap_crescent/utils/constants.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _SplashScreenView()
        );
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

    Timer(
        Duration(seconds: 1),
        () => Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => AssetsGridScreen(),
        ),
        (route) => false,//if you want to disable back feature set to false
      ));
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
            color: Colors.black,
            child: Center(
              child: 
                Image.asset(
                  "assets/images/logo.png",
                  width: 200,
                  height: 200,
                )
            ));
  }

  _setDefaultAppConfig() async {
    AppConfig firstBootConfig = await AppConfigRepository.instance
        .findByKey(Constants.appConfigFirstBootFlag);

    // This is first boot of application
    if (firstBootConfig.configValue == null) {
      firstBootConfig.configKey = Constants.appConfigFirstBootFlag;
      firstBootConfig.configValue = "false";

      await AppConfigRepository.instance.saveOrUpdateConfig(firstBootConfig);

      AppConfig appConfigShowDeviceAssetsFlagConfig = new AppConfig(
          configKey: Constants.appConfigShowDeviceAssetsFlag,
          configValue: "true");

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigShowDeviceAssetsFlagConfig);

      final PermissionState _ps = await PhotoManager.requestPermissionExtend();

      if (!_ps.isAuth) {
          ToastService.showError('Permission to device folders denied!');
        return Future.value([]);
        } 

      final List<AssetPathEntity> folders =
          await PhotoManager.getAssetPathList();
      folders.sort(
          (AssetPathEntity a, AssetPathEntity b) => a.name.compareTo(b.name));

      List<AssetPathEntity> cameraFolders = folders
          .where((folder) =>
              folder.name.toLowerCase() == "camera" ||
              folder.name.toLowerCase() == "pictures" ||
              folder.name.toLowerCase() == "portrait" ||
              folder.name.toLowerCase() == "selfies" ||
              folder.name.toLowerCase() == "portrait" ||
              folder.name.toLowerCase() == "raw" ||
              folder.name.toLowerCase() == "videos")
          .toList();

      AppConfig appConfigShowDeviceAssetsFoldersFlagConfig = new AppConfig(
          configKey: Constants.appConfigShowDeviceAssetsFolders,
          configValue: cameraFolders
              .map((assetPathEntity) => assetPathEntity.id)
              .join(","));

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigShowDeviceAssetsFoldersFlagConfig);

      AppConfig appConfigLoggedInFlagConfig = new AppConfig(
          configKey: Constants.appConfigLoggedInFlag,
          configValue: false.toString());

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigLoggedInFlagConfig);

      AppConfig appConfigThumbnailsFolderConfig = new AppConfig(
          configKey: Constants.appConfigThumbnailsFolder,
          configValue: 'thumbnails');

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigThumbnailsFolderConfig);

      AppConfig appConfigTempDownloadsFolderConfig = new AppConfig(
          configKey: Constants.appConfigTempDownloadsFolder,
          configValue: 'tempDownload');

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigTempDownloadsFolderConfig);

      AppConfig appConfigPermanentDownloadsFolderConfig = new AppConfig(
          configKey: Constants.appConfigPermanentDownloadsFolder,
          configValue: 'SnapCrescent');

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigPermanentDownloadsFolderConfig);
    }

  

  }

}
