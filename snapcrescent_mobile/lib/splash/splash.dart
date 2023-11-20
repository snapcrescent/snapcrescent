import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snapcrescent_mobile/appConfig/app_config_service.dart';
import 'package:snapcrescent_mobile/asset/screens/asset_list.dart';
import 'package:snapcrescent_mobile/common/model/base_model.dart';
import 'package:snapcrescent_mobile/localAsset/local_asset.dart';
import 'package:snapcrescent_mobile/localAsset/local_asset_service.dart';
import 'package:snapcrescent_mobile/metadata/metadata.dart';
import 'package:snapcrescent_mobile/metadata/metadata_service.dart';
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
    return Container(color: Colors.red);
  }

  _setDefaultAppConfig() async {
    bool allPermissionsApproved = await _requestPermissions();

    bool firstBoot = await AppConfigService().getFlag(Constants.appConfigFirstBootFlag, true);

    // This is first boot of application
    if (firstBoot == true) {
      await await AppConfigService().updateFlag(Constants.appConfigFirstBootFlag, false);

      if (allPermissionsApproved) {
        await _setDefaultSettings();
      }

      await _setSystemSettings();
    }

    if (!allPermissionsApproved) {
      _goToFallbackScreen();
    } else {
      await _loadLocaAssets();
      _goToDefaultLandingScreen();
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
        if (folder.name.toLowerCase() == defaultFolder.toLowerCase()) {
          deviceAssetFolders.add(folder);
        }
      }
    }

    await AppConfigService().updateConfig(Constants.appConfigShowDeviceAssetsFolders, deviceAssetFolders.map((folder) => folder.id).join(","));
    await AppConfigService().updateIntConfig(Constants.appConfigAutoBackupFrequency, Constants.defaultAutoBackupFrequency);
    await AppConfigService().updateDateConfig(Constants.appConfigLastSyncActivityTimestamp, Constants.lowDate, DateUtilities.timeStampFormat);
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
    Navigator.push(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => SettingsListScreen()));
  }

  _loadLocaAssets() async {
    List<String> selectedDeviceFolders = await AppConfigService().getStringListConfig(Constants.appConfigShowDeviceAssetsFolders);

    final albums = await PhotoManager.getAssetPathList();
    for (final album in albums) {
      if (selectedDeviceFolders.contains(album.id)) {
        await _loadLocaAssetsFromAlbum(album);
      }
    }
  }

  _loadLocaAssetsFromAlbum(AssetPathEntity album) async {
    //Look for latest entry in LOCAL_ASSET table for this album
    DateTime latestLoggedLocalAsset = await LocalAssetService().getMaxAssetDateByAlbum(album.id);

    FilterOptionGroup filterOption = FilterOptionGroup();
    filterOption.createTimeCond = DateTimeCond(min: latestLoggedLocalAsset, max: Constants.highDate);

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(filterOption: filterOption);

    album = albums.firstWhere((item) => item.id == album.id);

    final allAssets = await album.getAssetListRange(start: 0, end: 10000);

    for (final asset in allAssets) {
      bool metadataExists = await MetadataService().existByLocalAssetId(asset.id);

      //Local asset is not found
      if (metadataExists == false) {
        //Attempt to find by name to avoid file size calculation
        bool matchingMetadataList = await MetadataService().existByName(asset.title!);

        if (matchingMetadataList == true) {
          //Attempt to find by size as it might be a new asset
          File? assetFile = await asset.file;
          Metadata? metadata = await MetadataService().findByNameAndSize(asset.title!, assetFile!.lengthSync());

          //Found by name and size match. Update the db to save future processing time
          if (metadata != null) {
            metadata.localAssetId = asset.id;
            await MetadataService().saveOrUpdate(metadata);
          }
        }
      }

      LocalAsset? localAsset = await LocalAssetService().findByAssetId(asset.id);

      //The device asset is not logged in the app db yet.
      if (localAsset == null) {
        localAsset = LocalAsset(bean: BaseUiBean(id: null), localAssetId: asset.id, localAlbumId: album.id, creationDateTime: asset.createDateTime, syncedToServer: false);
        await LocalAssetService().saveOrUpdate(localAsset);
      }
    }
  }
}
