import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/utils/constants.dart';

class CommonUtils {
  
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
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
