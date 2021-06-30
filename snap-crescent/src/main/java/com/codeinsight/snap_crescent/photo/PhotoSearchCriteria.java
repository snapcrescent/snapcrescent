package com.codeinsight.snap_crescent.photo;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class PhotoSearchCriteria extends BaseSearchCriteria{

	private Boolean favorite;
	private String month;
	private String year;
}
