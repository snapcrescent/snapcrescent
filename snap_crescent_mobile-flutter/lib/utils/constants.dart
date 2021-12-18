class Constants {

  static final String appConfigFirstBootFlag = 'FIRST_BOOT';

  static final String appConfigLoggedInFlag = 'LOGGED_IN';
  static final String appConfigSessionToken = 'SESSION_TOKEN';

  static final String appConfigServerURL = 'SERVER_URL';
  static final String appConfigServerUserName = 'SERVER_USERNAME';
  static final String appConfigServerPassword = 'SERVER_PASSWORD';

  static final String appConfigAutoBackupFlag = 'AUTO_BACKUP';
  static final String appConfigAutoBackupFolders = 'AUTO_BACKUP_FOLDERS';

  static final String appConfigShowDeviceAssetsFlag = 'SHOW_DEVICE_ASSETS';
  static final String appConfigShowDeviceAssetsFolders = 'SHOW_DEVICE_ASSETS_FOLDERS';
  
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

enum ASSET_TYPE {  
   PHOTO,
   VIDEO
}

enum ResultType {  
   OPTION,
   SEARCH,
   FULL
}

enum Direction {  
   ASC,
   DESC
}

enum SyncProgress { 
   CONTACTING_SERVER,
   PROCESSING,
   DOWNLOADING_PHOTO_THUMNAILS,
   DOWNLOADING_VIDEO_THUMNAILS,
   UPLOADING_PHOTOS,
   UPLOADING_VIDEOS,
   SYNC_COMPLETED
}