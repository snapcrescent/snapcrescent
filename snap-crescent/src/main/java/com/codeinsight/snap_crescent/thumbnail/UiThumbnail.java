package com.codeinsight.snap_crescent.thumbnail;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiThumbnail extends BaseUiBean {

	private static final long serialVersionUID = 1567235158787189351L;

	private String name;
	private String base64EncodedThumbnail;
}
