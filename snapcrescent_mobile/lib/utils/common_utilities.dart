import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapcrescent_mobile/repository/app_config_repository.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class CommonUtilities {
  
   Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.photos.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<String> getPermanentDownloadsDirectory() async{

    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return directory.path + Platform.pathSeparator + 'Download';
    }
  }

  Future<String> getTempDownloadsDirectory() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    String temporaryDownloadsFolder = (await AppConfigRepository.instance.findByKey(Constants.appConfigThumbnailsFolder)).configValue!;
    String finalFolder = '$dir/$temporaryDownloadsFolder';
    await Directory(finalFolder).create();
    return finalFolder;
  }

  Future<String> getThumbnailDirectory() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    String thumbnailsFolder = (await AppConfigRepository.instance.findByKey(Constants.appConfigThumbnailsFolder)).configValue!;
    String finalFolder = '$dir/$thumbnailsFolder';
    await Directory(finalFolder).create();
    return finalFolder;
  }
}
