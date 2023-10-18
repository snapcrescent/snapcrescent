package com.snapcrescent.common.beans;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.snapcrescent.common.utils.Constant.Direction;
import com.snapcrescent.common.utils.Constant.ResultType;

import lombok.Data;

@Data
public class BaseSearchCriteria{

	private Long createdByUserId;
	private Long accessibleByUserId;

	private Long fromId;
	private Long toId;
	
	private List<Long> selectedIds = new ArrayList<>();
	private List<Long> ignoreIds = new ArrayList<>();
	
	private String searchKeyword;
	private Boolean active;
	private Date fromDate;
	private Date toDate;
	
	private String sortBy;
	private Direction sortOrder;
	
	private ResultType resultType;
	
	private Integer pageNumber = 0;
	private Integer resultPerPage = 10000;

}
