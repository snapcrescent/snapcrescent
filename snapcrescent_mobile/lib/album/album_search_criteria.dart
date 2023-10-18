import 'package:snapcrescent_mobile/common/model/base_search_criteria.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AlbumSearchCriteria extends BaseSearchCriteria {
  
  AlbumSearchCriteria(
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

  factory AlbumSearchCriteria.defaultCriteria() {
    return AlbumSearchCriteria(
      resultType : ResultType.SEARCH,
      pageNumber : 0,
      resultPerPage : 1000,
      active: true
    );
  }          

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();

    return map;
  }
}
