package com.snapcrescent.asset;


import com.snapcrescent.common.beans.BaseUiBean;
import com.snapcrescent.metadata.UiMetadata;
import com.snapcrescent.thumbnail.UiThumbnail;

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
	
	private String token;

}
