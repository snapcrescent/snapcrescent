package com.codeinsight.snap_crescent.video;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class VideoSearchCriteria extends BaseSearchCriteria{

	private Boolean favorite;
	private String month;
	private String year;
}
