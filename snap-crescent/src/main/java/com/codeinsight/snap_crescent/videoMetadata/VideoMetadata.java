package com.codeinsight.snap_crescent.videoMetadata;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.common.BaseEntity;
import com.codeinsight.snap_crescent.location.Location;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "VIDEO_METADATA")
@Data
@EqualsAndHashCode(callSuper = false)
public class VideoMetadata extends BaseEntity {

	private static final long serialVersionUID = 1567235158787189351L;

	private String name;
	private String internalName;
	private String path;
	private String size;
	private String fileTypeName;
	private String fileTypeLongName;
	private String mimeType;
	private String fileExtension;
	private String model;
	private String height;
	private String width;
	private int orientation;
	private String fstop;
	
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "LOCATION_ID", insertable = false, updatable = false)
	private Location location;

	@Column(name = "LOCATION_ID", insertable = true, updatable = true)
	private Long locationId;	
}
