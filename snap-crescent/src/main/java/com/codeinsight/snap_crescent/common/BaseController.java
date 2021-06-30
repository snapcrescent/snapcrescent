package com.codeinsight.snap_crescent.common;

import java.util.Map;

import org.springframework.data.domain.Sort.Direction;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

public class BaseController {

	protected void parseCommonSearchParams(Map<String, String> searchParams, BaseSearchCriteria searchCriteria) {
		if (searchParams.get("searchInput") != null) {
			searchCriteria.setSearchKeyword(searchParams.get("searchInput"));
		}

		if (searchParams.get("page") != null) {
			searchCriteria.setPageNumber(Integer.parseInt(searchParams.get("page")));
		}

		if (searchParams.get("size") != null) {
			searchCriteria.setResultPerPage(Integer.parseInt(searchParams.get("size")));
		}

		if (searchParams.get("sort") != null) {
			searchCriteria.setSortBy(searchParams.get("sort"));
		}

		if (searchParams.get("sortDirection") != null && searchParams.get("sortDirection").equals("desc")) {
			searchCriteria.setSortOrder(Direction.DESC);
		} else {
			searchCriteria.setSortOrder(Direction.ASC);
		}

		if (searchParams.get("active") != null) {
			searchCriteria.setActive(Boolean.valueOf(searchParams.get("active")));
		} else {
			searchCriteria.setActive(true);
		}

		if (searchParams.get("resultType") != null) {
			searchCriteria.setResultType(ResultType.valueOf(searchParams.get("resultType")));
		}
	}

}
