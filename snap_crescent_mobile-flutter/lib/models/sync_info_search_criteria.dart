import 'package:snap_crescent/models/base_search_criteria.dart';
import 'package:snap_crescent/utils/constants.dart';

class SyncInfoSearchCriteria extends BaseSearchCriteria {
  
  SyncInfoSearchCriteria(
      {searchKeyword,
      active,
      fromDate,
      toDate,
      sortBy,
      sortOrder,
      resultType,
      pageNumber,
      resultPerPage})
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

  factory SyncInfoSearchCriteria.defaultCriteria() {
    return SyncInfoSearchCriteria(
      sortBy : 'syncInfo.id',
      sortOrder : Direction.ASC,
      resultType : ResultType.SEARCH,
      pageNumber : 0,
      resultPerPage : 1000
    );
  }          

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    return map;
  }
}
