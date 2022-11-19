package com.codeinsight.snap_crescent.asset;

import com.codeinsight.snap_crescent.common.beans.BaseSearchCriteria;
import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class AssetSearchCriteria extends BaseSearchCriteria{

	private ASSET_TYPE assetType;
	private Boolean favorite;
}
