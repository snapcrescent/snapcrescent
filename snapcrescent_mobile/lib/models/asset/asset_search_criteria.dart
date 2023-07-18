import 'package:snapcrescent_mobile/models/common/base_search_criteria.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AssetSearchCriteria extends BaseSearchCriteria {
  int? assetType;
  bool? favorite;

  AssetSearchCriteria(
      {searchKeyword,
      active,
      fromDate,
      toDate,
      sortBy,
      sortOrder,
      resultType,
      pageNumber,
      resultPerPage,
      this.assetType,
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

  factory AssetSearchCriteria.defaultCriteria() {
    return AssetSearchCriteria(
      sortBy : 'metadata.creationDateTime',
      sortOrder : Direction.DESC,
      resultType : ResultType.SEARCH,
      pageNumber : 0,
      resultPerPage : 1000,
      active: true
    );
  }          

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    if (assetType != null) {
      map['assetType'] = assetType;
    }

    if (favorite != null) {
      map['favorite'] = favorite;
    }

    return map;
  }
}
