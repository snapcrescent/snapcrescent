package com.codeinsight.snap_crescent.sync_info;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class SyncInfoSearchCriteria extends BaseSearchCriteria{

	private Boolean favorite;
	private String month;
	private String year;
}
