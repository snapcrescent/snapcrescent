

import 'package:snapcrescent_mobile/common/model/base_response.dart';

class BaseResponseBean<ID, T> extends BaseResponse {
  T? object;
  List<T>? objects;
  ID? objectId;

  int? totalResultsCount;
  int? resultCountPerPage;
  int? currentPageIndex;

  BaseResponseBean(
      {logoutResponse,
      message,
      this.object,
      this.objects,
      this.objectId,
      this.totalResultsCount,
      this.resultCountPerPage,
      this.currentPageIndex})
      : super(logoutResponse: logoutResponse, message: message);

  factory BaseResponseBean.defaultResponse() {
    return BaseResponseBean(
      objects : [],
      totalResultsCount : 0,
      resultCountPerPage : 0,
      currentPageIndex : 0,
    );
  } 

  factory BaseResponseBean.fromJson(Map<String, dynamic> json, Function fromJsonModel) {
    final objects = json['objects'].cast<Map<String, dynamic>>();
    return BaseResponseBean(
      logoutResponse: json['logoutResponse'],
      message: json['message'],
      object: json['object'] == null ? null : fromJsonModel(json['object']),
      objects: json['objects']  == null ? null : List<T>.from(objects.map((objectJson) => fromJsonModel(objectJson))),
      objectId: json['objectId'],
      totalResultsCount: json['totalResultsCount'],
      resultCountPerPage: json['resultCountPerPage'],
      currentPageIndex: json['currentPageIndex'],
    );
  }
}
