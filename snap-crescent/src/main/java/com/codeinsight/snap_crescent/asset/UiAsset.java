package com.codeinsight.snap_crescent.asset;


import com.codeinsight.snap_crescent.common.beans.BaseUiBean;
import com.codeinsight.snap_crescent.metadata.UiMetadata;
import com.codeinsight.snap_crescent.thumbnail.UiThumbnail;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiAsset extends BaseUiBean {
	/**
	* 
	*/
	private static final long serialVersionUID = -873185495294499014L;
	
	private Boolean active;
	
	private int assetType;
	
	private UiThumbnail thumbnail;
	private Long thumbnailId;

	private UiMetadata metadata;
	private Long metadataId;
	
	private Boolean favorite = false;

}
