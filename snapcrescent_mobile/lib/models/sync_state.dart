class SyncState  {
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

  downloadedPercentageString() {
    return _getPercentageString(downloadedAssetCount, totalServerAssetCount);
  }

  uploadPercentageString() {
    return _getPercentageString(uploadedAssetCount, totalLocalAssetCount);
  }

  _getPercentage(int? count, int? total) {
    if(total == 0) {
      return 0;
    }
    
    return (count! * 100 / total!).ceil();
  }

  _getPercentageString(int? count, int? total) {
    if(total == 0) {
      return 0.toStringAsFixed(2) + "%";
    }
    
    return (count! * 100 / total!).toStringAsFixed(2) + "%";
  }

  SyncState(
        this.downloadedAssetCount,
        this.totalServerAssetCount,
        this.uploadedAssetCount,
        this.totalLocalAssetCount,
      );

  static SyncState fromJsonModel(Map<String, dynamic> json) => SyncState.fromJson(json);

  factory SyncState.fromJson(Map<String, dynamic> json) {
    return SyncState(
      json['downloadedAssetCount'],
      json['totalServerAssetCount'],
      json['uploadedAssetCount'],
      json['totalLocalAssetCount']
    );
  }

  Map toJson() => {
    'downloadedAssetCount' : downloadedAssetCount,
    'totalServerAssetCount' : totalServerAssetCount,
    'uploadedAssetCount' : uploadedAssetCount,
    'totalLocalAssetCount' : totalLocalAssetCount,
  };

}
