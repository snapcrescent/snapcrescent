import 'package:flutter/material.dart';
import 'package:snap_crescent/models/app_config.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/screens/grid/assets_grid.dart';
import 'package:snap_crescent/screens/settings/settings.dart';
import 'package:snap_crescent/services/settings_service.dart';
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

  }

  @override
  Widget build(BuildContext context) {
    return  Container(
            color: Colors.black);
  }

  _setDefaultAppConfig() async {

    bool startWithSettings = false;

    AppConfig firstBootConfig = await AppConfigRepository.instance
        .findByKey(Constants.appConfigFirstBootFlag);

    // This is first boot of application
    if (firstBootConfig.configValue == null) {
      firstBootConfig.configKey = Constants.appConfigFirstBootFlag;
      firstBootConfig.configValue = "false";

      await AppConfigRepository.instance.saveOrUpdateConfig(firstBootConfig);

      AppConfig appConfigShowDeviceAssetsFlagConfig = new AppConfig(
          configKey: Constants.appConfigShowDeviceAssetsFlag,
          configValue: "false");

      await AppConfigRepository.instance
          .saveOrUpdateConfig(appConfigShowDeviceAssetsFlagConfig);

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

      startWithSettings = true;
      
    } else {
      if((await SettingsService.instance.isUserLoggedIn()) == false) {
        startWithSettings = true;
      }
    }

      Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) => AssetsGridScreen(),
                                      ),
                                      (route) => false,//if you want to disable back feature set to false
                                    );

      if(startWithSettings) {
        Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => SettingsScreen()));
      }
      
      

    

  

  }

}
