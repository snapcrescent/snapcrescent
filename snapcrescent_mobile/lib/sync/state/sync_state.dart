import 'package:flutter/material.dart';

class SyncState extends ChangeNotifier {
  int _downloadedAssetCount = 0;
  int _totalServerAssetCount = 0;

  int _uploadedAssetCount = 0;
  int _totalLocalAssetCount = 0;

  downloadPercentage() {
    return _getPercentage(_downloadedAssetCount, _totalServerAssetCount);
  }

  uploadPercentage() {
    return _getPercentage(_uploadedAssetCount, _totalLocalAssetCount);
  }

  downloadPercentageString() {
    return _getPercentageString(_downloadedAssetCount, _totalServerAssetCount);
  }

  uploadPercentageString() {
    return _getPercentageString(_uploadedAssetCount, _totalLocalAssetCount);
  }

  _getPercentageString(int? count, int? total) {
    if (total == 0) {
      return "${0.toStringAsFixed(2)}%";
    }

    return "${(count! * 100 / total!).toStringAsFixed(2)}%";
  }

  _getPercentage(int? count, int? total) {
    if (total == 0) {
      return 0;
    }

    return (count! * 100 / total!).ceil();
  }

  int getDownloadedAssetCount() {
    return _downloadedAssetCount;
  }

  void setDownloadedAssetCount(int downloadedAssetCount) {
    _downloadedAssetCount = downloadedAssetCount;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  int getUploadedAssetCount() {
    return _uploadedAssetCount;
  }

  void setUploadedAssetCount(int uploadedAssetCount) {
    _uploadedAssetCount = uploadedAssetCount;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  int getTotalServerAssetCount() {
    return _totalServerAssetCount;
  }

  void setTotalServerAssetCount(int totalServerAssetCount) {
    _totalServerAssetCount = totalServerAssetCount;
  }

  int getTotalLocalAssetCount() {
    return _totalLocalAssetCount;
  }

  void setTotalLocalAssetCount(int totalLocalAssetCount) {
    _totalLocalAssetCount = totalLocalAssetCount;
  }
}
