package com.codeinsight.snap_crescent.asset;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class AssetSearchCriteria extends BaseSearchCriteria{

	private Integer assetType;
	private Boolean favorite;
}
