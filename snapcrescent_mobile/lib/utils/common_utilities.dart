import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:snapcrescent_mobile/appConfig/app_config_service.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class CommonUtilities {

  Future<String> getRootDirectory() async{

    if (Platform.isAndroid) {
      return "/storage/emulated/0";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }
  
  Future<String> getPermanentDownloadsDirectory() async{

    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }

  Future<String> getTempDownloadsDirectory() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    String temporaryDownloadsFolder = (await AppConfigService().getConfig(Constants.appConfigThumbnailsFolder))!;
    String finalFolder = '$dir/$temporaryDownloadsFolder';
    await Directory(finalFolder).create();
    return finalFolder;
  }

  Future<String> getThumbnailDirectory() async{
    String dir = (await getApplicationDocumentsDirectory()).path;
    String thumbnailsFolder = (await AppConfigService().getConfig(Constants.appConfigThumbnailsFolder))!;
    String finalFolder = '$dir/$thumbnailsFolder';
    await Directory(finalFolder).create();
    return finalFolder;
  }
}
