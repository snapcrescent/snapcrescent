import 'package:snap_crescent/utils/constants.dart';

class SyncState  {

  SyncProgress syncProgressState;

  int downloadedAssetCount = 0;
  int totalServerAssetCount = 0;

  int uploadedAssetCount = 0;
  int totalLocalAssetCount = 0;

  downloadedPercentage() {
    return _getPercentage(downloadedAssetCount, totalServerAssetCount);
  }

  uploadPercentage() {
    return _getPercentage(uploadedAssetCount, totalLocalAssetCount);
  }

  _getPercentage(int? count, int? total) {
    if(total == 0) {
      return "0%";
    }
    
    return (count! * 100 / total!).toStringAsFixed(2) + "%";
  }

  SyncState(
        this.syncProgressState,
        this.downloadedAssetCount,
        this.totalServerAssetCount,
        this.uploadedAssetCount,
        this.totalLocalAssetCount,
      );

}
