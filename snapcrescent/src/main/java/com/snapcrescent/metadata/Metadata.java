package com.snapcrescent.metadata;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.location.Location;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class Metadata extends BaseEntity {

	private static final long serialVersionUID = 1567235158787189351L;

	private String name;
	private String internalName;
	private String path;
	private long size;
	private String fileTypeName;
	private String fileTypeLongName;
	private String mimeType;
	private String fileExtension;
	private String model;
	private long height;
	private long width;
	private int orientation;
	private String fstop;
	private long hash;
	private long duration;
	
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "LOCATION_ID", insertable = false, updatable = false)
	private Location location;

	@Column(name = "LOCATION_ID", insertable = true, updatable = true)
	private Long locationId;	
}
