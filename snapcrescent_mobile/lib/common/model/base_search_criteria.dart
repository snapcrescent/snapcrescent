
import 'package:snapcrescent_mobile/utils/constants.dart';

class BaseSearchCriteria {
  String? searchKeyword;
  bool? active;
  DateTime? fromDate;
  DateTime? toDate;

  String? sortBy;
  Direction? sortOrder;

  ResultType? resultType;

  int? pageNumber = 0;
  int? resultPerPage = 1000;

  List<String>? ignoreIds;

  BaseSearchCriteria(
      {this.searchKeyword,
      this.active,
      this.fromDate,
      this.toDate,
      this.sortBy,
      this.sortOrder,
      this.resultType,
      this.pageNumber,
      this.resultPerPage,
      this.ignoreIds
      });

  factory BaseSearchCriteria.fromJson(Map<String, dynamic> json) {
    return BaseSearchCriteria(
        searchKeyword: json['searchKeyword'],
        active: json['active'],
        fromDate: json['fromDate'],
        toDate: json['toDate'],
        sortBy: json['sortBy'],
        sortOrder:  json['sortOrder'] != null ?  Direction.findByLabel(json['sortOrder']) : Direction.ASC,
        resultType: json['resultType'] != null ?  ResultType.findByLabel(json['resultType']) : ResultType.SEARCH,
        pageNumber: json['pageNumber'],
        resultPerPage: json['resultPerPage'],
        ignoreIds: json['ignoreIds'] != null ? json['ignoreIds'].split(',') : [],
        );
  }    

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};

    if (searchKeyword != null) {
      map['searchKeyword'] = searchKeyword;
    }

    if (active != null) {
      map['active'] = active;
    }

    if (fromDate != null) {
      map['fromDate'] = fromDate!.millisecondsSinceEpoch;
    }

    if (toDate != null) {
      map['toDate'] = toDate!.millisecondsSinceEpoch;
    }

    if (sortBy != null) {
      map['sortBy'] = sortBy;
    }

    if (sortOrder != null) {
      map['sortOrder'] = sortOrder.toString().split('.').last;
    }

    if (resultType != null) {
      map['resultType'] = resultType.toString().split('.').last;
    }

    if (pageNumber != null) {
      map['pageNumber'] = pageNumber;
    }

    if (resultPerPage != null) {
      map['resultPerPage'] = resultPerPage;
    }

    if (ignoreIds != null) {
      map['ignoreIds'] = ignoreIds!.join(",");
    }

    return map;
  }
}
