package com.snapcrescent.common;

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourceRegion;

import com.snapcrescent.common.beans.BaseSearchCriteria;
import com.snapcrescent.common.security.CoreService;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.Direction;
import com.snapcrescent.common.utils.Constant.ResourceRegionType;
import com.snapcrescent.common.utils.Constant.ResultType;

public class BaseController {
	
	@Autowired
	protected CoreService coreService;

	protected void parseCommonSearchParams(Map<String, String> searchParams, BaseSearchCriteria searchCriteria) {
		
		if(coreService.getAppUser() != null) {
			searchCriteria.setUserId(coreService.getAppUser().getId());	
		}
		
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

		if (searchParams.get("fromDate") != null) {
			searchCriteria.setFromDate(new Date(Long.parseLong(searchParams.get("fromDate"))));
		}

		if (searchParams.get("toDate") != null) {
			searchCriteria.setToDate(new Date(Long.parseLong(searchParams.get("toDate"))));
		}
	}

	protected ResourceRegion resourceRegion(AssetType assetType, ResourceRegionType resourceRegionType,
			Resource assetFile, String httpRangeList) throws IOException {

		long chunkSize = 5 * 1024 * 1024;
		long contentLength = assetFile.contentLength();
		if (httpRangeList != null) {

			String[] ranges = httpRangeList.split("-");

			long rangeStart = Long.parseLong(ranges[0].substring(6));
			long rangeEnd = 0;

			if (ranges.length > 1) {
				rangeEnd = Long.parseLong(ranges[1]);
			} else {
				rangeEnd = rangeStart + chunkSize;
			}

			long rangeLength = 0;

			if (resourceRegionType == ResourceRegionType.STREAM) {
				rangeLength = Math.min(chunkSize, rangeEnd - rangeStart + 1);
			} else if (resourceRegionType == ResourceRegionType.DOWNLOAD) {
				rangeLength = rangeEnd - rangeStart + 1;
			}

			return new ResourceRegion(assetFile, rangeStart, rangeLength);
		} else {

			if (assetType == AssetType.VIDEO) {
				long rangeLength = Math.min(chunkSize, contentLength);
				return new ResourceRegion(assetFile, 0L, rangeLength);
			} else {
				return new ResourceRegion(assetFile, 0L, contentLength);
			}

		}
	}

}
