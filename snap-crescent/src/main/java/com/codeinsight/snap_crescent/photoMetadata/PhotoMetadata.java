package com.codeinsight.snap_crescent.photoMetadata;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.location.Location;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "metadata")
public class PhotoMetadata implements Serializable {

	private static final long serialVersionUID = 1567235158787189351L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@Column(nullable = false)
	private String name;

	@Column(nullable = false)
	private String path;

	@Column(nullable = false)
	private String size;

	private Date createdDate;

	private String fileTypeName;

	private String fileTypeLongName;

	private String mimeType;

	@Column(nullable = false)
	private String fileExtension;

	private String model;

	private String height;

	private String width;
	
	private int orientation;
	
	private String fspot;
	
	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "Location_Id", insertable = false, updatable = false)
	private Location location;

	@Column(name = "Location_Id", insertable = true, updatable = true)
	private Long locationId;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public String getSize() {
		return size;
	}

	public void setSize(String size) {
		this.size = size;
	}

	public Date getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}

	public String getFileTypeName() {
		return fileTypeName;
	}

	public void setFileTypeName(String fileTypeName) {
		this.fileTypeName = fileTypeName;
	}

	public String getFileTypeLongName() {
		return fileTypeLongName;
	}

	public void setFileTypeLongName(String fileTypeLongName) {
		this.fileTypeLongName = fileTypeLongName;
	}

	public String getMimeType() {
		return mimeType;
	}

	public void setMimeType(String mimeType) {
		this.mimeType = mimeType;
	}

	public String getFileExtension() {
		return fileExtension;
	}

	public void setFileExtension(String fileExtension) {
		this.fileExtension = fileExtension;
	}

	public String getHeight() {
		return height;
	}

	public void setHeight(String height) {
		this.height = height;
	}

	public String getWidth() {
		return width;
	}

	public void setWidth(String width) {
		this.width = width;
	}

	public String getModel() {
		return model;
	}

	public void setModel(String model) {
		this.model = model;
	}

	public int getOrientation() {
		return orientation;
	}

	public void setOrientation(int orientation) {
		this.orientation = orientation;
	}

	public String getFspot() {
		return fspot;
	}

	public void setFspot(String fspot) {
		this.fspot = fspot;
	}

	public Location getLocation() {
		return location;
	}

	public void setLocation(Location location) {
		this.location = location;
	}

	public Long getLocationId() {
		return locationId;
	}

	public void setLocationId(Long locationId) {
		this.locationId = locationId;
	}
}
