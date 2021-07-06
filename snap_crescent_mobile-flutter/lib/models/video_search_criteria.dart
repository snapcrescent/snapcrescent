import 'package:snap_crescent/models/base_search_criteria.dart';
import 'package:snap_crescent/utils/constants.dart';

class VideoSearchCriteria extends BaseSearchCriteria {
  bool? favorite;

  VideoSearchCriteria(
      {searchKeyword,
      active,
      fromDate,
      toDate,
      sortBy,
      sortOrder,
      resultType,
      pageNumber,
      resultPerPage,
      this.favorite})
      : super(
            searchKeyword: searchKeyword,
            active: active,
            fromDate: fromDate,
            toDate: toDate,
            sortBy: sortBy,
            sortOrder: sortOrder,
            resultType: resultType,
            pageNumber: pageNumber,
            resultPerPage: resultPerPage);

  factory VideoSearchCriteria.defaultCriteria() {
    return VideoSearchCriteria(
      sortBy : 'videoMetadata.creationDatetime',
      sortOrder : Direction.DESC,
      resultType : ResultType.SEARCH,
      pageNumber : 0,
      resultPerPage : 1000
    );
  }          

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    if (favorite != null) {
      map['favorite'] = favorite;
    }

    return map;
  }
}
