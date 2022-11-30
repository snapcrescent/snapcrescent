package com.codeinsight.snap_crescent.common;

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourceRegion;
import org.springframework.data.domain.Sort.Direction;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
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
		
		if (searchParams.get("fromDate") != null) {
			searchCriteria.setFromDate(new Date(Long.parseLong(searchParams.get("fromDate"))));
		}
		
		if (searchParams.get("toDate") != null) {
			searchCriteria.setToDate(new Date(Long.parseLong(searchParams.get("toDate"))));
		}
	}
	
		protected ResourceRegion resourceRegion(AssetType assetType,  Resource assetFile,String httpRangeList) throws IOException  {
		
		long chunkSize = 1 * 1024 * 1024;
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
			
			long rangeLength = Math.min(chunkSize, rangeEnd - rangeStart + 1);
			return new ResourceRegion(assetFile, rangeStart, rangeLength);
		} else {
			
			if(assetType == AssetType.VIDEO) {
				long rangeLength = Math.min(chunkSize, contentLength);
				return new  ResourceRegion(assetFile, 0L, rangeLength);	
			} else {
				return new  ResourceRegion(assetFile, 0L, contentLength);
			}
			
	        
	        
		}
	}

}
