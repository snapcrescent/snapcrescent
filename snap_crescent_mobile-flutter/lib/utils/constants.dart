class Constants {

  static final String appConfigServerURL = 'SERVER_URL';
  static final String appConfigServerUserName = 'SERVER_USERNAME';
  static final String appConfigServerPassword = 'SERVER_PASSWORD';

  static final String appConfigAutoBackupFlag = 'AUTO_BACKUP';
  static final String appConfigAutoBackupFolders = 'AUTO_BACKUP_FOLDERS';

  
}

enum AssetSearchProgress { 
   IDLE,
   SEARCHING,
   ASSETS_FOUND,
   ASSETS_NOT_FOUND
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