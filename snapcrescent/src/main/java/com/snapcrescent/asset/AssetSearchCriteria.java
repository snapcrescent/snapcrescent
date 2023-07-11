package com.snapcrescent.asset;

import com.snapcrescent.common.beans.BaseSearchCriteria;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper=false)
public class AssetSearchCriteria extends BaseSearchCriteria{

	private Integer assetType;
	private Boolean favorite;
	private Long albumId;
	private Long createdByUserId;
}
