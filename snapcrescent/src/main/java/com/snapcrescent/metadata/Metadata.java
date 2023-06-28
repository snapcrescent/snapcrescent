package com.snapcrescent.metadata;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;

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
	private Long height;
	private Long width;
	private int orientation;
	private String fstop;
	private long hash;
	private Long duration;
	
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "LOCATION_ID", insertable = false, updatable = false)
	private Location location;

	@Column(name = "LOCATION_ID", insertable = true, updatable = true)
	private Long locationId;	
}
