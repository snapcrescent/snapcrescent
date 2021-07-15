package com.codeinsight.snap_crescent.common;

import java.util.Map;

import org.springframework.data.domain.Sort.Direction;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

public class BaseController {

	protected void parseCommonSearchParams(Map<String, String> searchParams, BaseSearchCriteria searchCriteria) {
		if (searchParams.get("searchKeyword") != null) {
			searchCriteria.setSearchKeyword(searchParams.get("searchKeyword"));
		}

		if (searchParams.get("pageNumber") != null) {
			searchCriteria.setPageNumber(Integer.parseInt(searchParams.get("pageNumber")));
		}

		if (searchParams.get("resultPerPage") != null) {
			searchCriteria.setResultPerPage(Integer.parseInt(searchParams.get("resultPerPage")));
		}

		if (searchParams.get("sortBy") != null) {
			searchCriteria.setSortBy(searchParams.get("sortBy"));
		}

		if (searchParams.get("sortOrder") != null && searchParams.get("sortOrder").equalsIgnoreCase("desc")) {
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
