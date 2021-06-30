package com.codeinsight.snap_crescent.common.beans;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.data.domain.Sort.Direction;

import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;

import lombok.Data;

@Data
public class BaseSearchCriteria{

	private List<String> selectedIds = new ArrayList<>();
	
	private String searchKeyword;
	private Boolean active;
	private Date fromDate;
	private Date toDate;
	
	private String sortBy;
	private Direction sortOrder;
	
	private ResultType resultType;
	
	private Integer pageNumber = 0;
	private Integer resultPerPage = 100000;

}
