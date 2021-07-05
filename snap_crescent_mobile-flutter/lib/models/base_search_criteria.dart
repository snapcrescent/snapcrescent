
import 'package:snap_crescent/utils/constants.dart';

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

  BaseSearchCriteria(
      {this.searchKeyword,
      this.active,
      this.fromDate,
      this.toDate,
      this.sortBy,
      this.sortOrder,
      this.resultType,
      this.pageNumber,
      this.resultPerPage});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();

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

    return map;
  }
}
