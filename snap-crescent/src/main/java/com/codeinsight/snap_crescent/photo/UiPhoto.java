package com.codeinsight.snap_crescent.photo;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;
import com.codeinsight.snap_crescent.photoMetadata.UiPhotoMetadata;
import com.codeinsight.snap_crescent.thumbnail.UiThumbnail;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiPhoto extends BaseUiBean {
	/**
	* 
	*/
	private static final long serialVersionUID = -873185495294499014L;
	
	private UiThumbnail thumbnail;
	private Long thumbnailId;

	private UiPhotoMetadata photoMetadata;
	private Long photoMetadataId;
	
	private Boolean favorite = false;

}
