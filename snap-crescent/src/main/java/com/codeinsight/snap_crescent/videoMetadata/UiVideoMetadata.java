package com.codeinsight.snap_crescent.videoMetadata;

import java.util.Date;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;
import com.codeinsight.snap_crescent.location.UiLocation;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiVideoMetadata extends BaseUiBean {

	private static final long serialVersionUID = 1567235158787189351L;

	private String name;
	private String size;
	private Date createdDate;
	private String fileTypeName;
	private String fileTypeLongName;
	private String mimeType;
	private String fileExtension;
	private String model;
	private String height;
	private String width;
	private int orientation;
	private String fstop;
	private UiLocation location;
	private Long locationId;
}
