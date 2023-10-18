
import 'package:snapcrescent_mobile/common/model/base_search_criteria.dart';
import 'package:snapcrescent_mobile/utils/constants.dart';

class AssetSearchCriteria extends BaseSearchCriteria {
  int? assetType;
  bool? favorite;
  int? fromId;

  AssetSearchCriteria(
      {
      bean,
      this.assetType,
      this.favorite,
      this.fromId,
      })
      : super(
            searchKeyword: bean.searchKeyword,
            active: bean.active,
            fromDate: bean.fromDate,
            toDate: bean.toDate,
            sortBy: bean.sortBy,
            sortOrder: bean.sortOrder,
            resultType: bean.resultType,
            pageNumber: bean.pageNumber,
            resultPerPage: bean.resultPerPage);

  factory AssetSearchCriteria.defaultCriteria() {
    BaseSearchCriteria bean = BaseSearchCriteria(
      sortBy : 'metadata.creationDateTime',
      sortOrder : Direction.DESC,
      resultType : ResultType.SEARCH,
      pageNumber : 0,
      resultPerPage : 1000,
      active: true
    );
    return AssetSearchCriteria( 
      bean:bean
    );
  }

  factory AssetSearchCriteria.fromJson(Map<String, dynamic> json) {
    return AssetSearchCriteria(
      bean: BaseSearchCriteria.fromJson(json),
      assetType: json['assetType'],
      favorite: json['favorite'],
    );
  }          

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();

    if (assetType != null) {
      map['assetType'] = assetType;
    }

    if (favorite != null) {
      map['favorite'] = favorite;
    }

    return map;
  }
}
