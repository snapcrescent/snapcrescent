package com.codeinsight.snap_crescent.common.beans;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class BaseResponseBean<ID,T> extends BaseResponse {

	private T object;
	private List<T> objects = new ArrayList<>(0);
	private ID objectId;
	
	private int totalResultsCount;
	private int resultCountPerPage;
	private int currentPageIndex;
	
}
