package com.codeinsight.snap_crescent.video;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;
import com.codeinsight.snap_crescent.videoMetadata.UiVideoMetadata;
import com.codeinsight.snap_crescent.thumbnail.UiThumbnail;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiVideo extends BaseUiBean {
	/**
	* 
	*/
	private static final long serialVersionUID = -873185495294499014L;
	
	private UiThumbnail thumbnail;
	private Long thumbnailId;

	private UiVideoMetadata videoMetadata;
	private Long videoMetadataId;
	
	private Boolean favorite = false;

}
