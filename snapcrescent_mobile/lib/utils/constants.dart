import 'package:intl/intl.dart';

class Constants {

  static const String appConfigFirstBootFlag = 'FIRST_BOOT';

  static const String appConfigLoggedInFlag = 'LOGGED_IN';
  static const String appConfigSessionToken = 'SESSION_TOKEN';

  static const String appConfigServerURL = 'SERVER_URL';
  static const String appConfigServerUserName = 'SERVER_USERNAME';
  static const String appConfigServerPassword = 'SERVER_PASSWORD';

  static const String appConfigAutoBackupFlag = 'AUTO_BACKUP';
  static const String appConfigAutoBackupFolders = 'AUTO_BACKUP_FOLDERS';
  static const String appConfigAutoBackupFrequency = 'AUTO_BACKUP_FREQUENCY';
  
  static const String appConfigSyncInProgress = 'SYNC_IN_PROGRESS';
  static const String appConfigLastSyncActivityTimestamp = 'LAST_SYNC_ACTIVITY_TIMESTAMP';

  static const String appConfigCacheLocallyFlag = 'CACHE_LOCALLY';
  static const String appConfigLocalCacheAge = 'LOCAL_CACHE_AGE';

  static const String appConfigShowDeviceAssetsFlag = 'SHOW_DEVICE_ASSETS';
  static const String appConfigShowDeviceAssetsFolders = 'SHOW_DEVICE_ASSETS_FOLDERS';

  static const String appConfigThumbnailsFolder = 'THUMBNAILS_FOLDER';
  static const String appConfigTempDownloadsFolder = 'TEMP_DOWNLOADS_FOLDER';
  static const String appConfigPermanentDownloadsFolder = 'PERMANENT_DOWNLOADS_FOLDER';

  static const String appConfigShowLoginPromptFlag = 'SHOW_LOGIN_PROMPT';
  static const String appConfigShowAutoBackupPromptFlag = 'SHOW_AUTO_BACKUP_PROMPT';


  static const String defaultNotificationChannel = 'Snap-Crescent';
  static const String downloadProgressNotificationChannel = 'Download Progress';
  static const String uploadProgressNotificationChannel = 'Upload Progress';

  static const int defaultAutoBackupFrequency = 1 * 60;


  static const int notificationChannelId = 0213;
  static const int notificationChannelName = 0213;
  
  static final DateFormat defaultYearFormatter = DateFormat('E, MMM dd, yyyy');

  static final List<String> androidDefaultDeviceFolderList = ["Camera"];
  static final List<String> iosDefaultDeviceFolderList = ["Recent"];

  static final DateTime defaultLastSyncActivityTimestamp = DateTime(2000, 1, 1, 0, 0, 0, 0, 0);

  static const int defaultSyncResultPerPage = 5;
}

enum AssetSearchProgress { 
   IDLE,
   PROCESSING,
   ASSETS_FOUND
}

enum AssetSource {  
   CLOUD,
   DEVICE
}

enum AppAssetType {  
   PHOTO(1),
   VIDEO(2);

   final int id;
   const AppAssetType(this.id);
}

enum ResultType {  
   OPTION("OPTION"),
   SEARCH("SEARCH"),
   FULL("FULL");

   final String label;

  const ResultType(this.label);

  static ResultType? findByLabel(String label) {
    for (var value in ResultType.values) {
      if(value.label == label) {
        return value;
      }
    }
    return null;
  }
}

enum Direction {  
   ASC("ASC"),
   DESC("DESC");

  final String label;

  const Direction(this.label);

  static Direction? findByLabel(String label) {
    for (var value in Direction.values) {
      if(value.label == label) {
        return value;
      }
    }
    return null;
  }
}

enum AutoBackupFrequencyType { 
    HOURS,
    DAYS
  }