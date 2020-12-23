package com.codeinsight.snap_crescent.photoMetadata;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "METADATA")
public class PhotoMetadata implements Serializable {

	private static final long serialVersionUID = 1567235158787189351L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "ID")
	private long id;

	@Column(name = "NAME", nullable = false)
	private String name;

	@Column(name = "PATH", nullable = false)
	private String path;

	@Column(name = "SIZE", nullable = false)
	private String size;

	@Column(name = "CREATED_DATE")
	private Date createdDate;

	@Column(name = "MODIFIED_DATE")
	private Date modifiedDate;

	@Column(name = "FILE_TYPE_NAME")
	private String fileTypeName;

	@Column(name = "FILE_TYPE_LONG_NAME")
	private String fileTypeLongName;

	@Column(name = "MIME_TYPE")
	private String mimeType;

	@Column(name = "FILE_EXTENSION", nullable = false)
	private String fileExtension;

	@Column(name = "GEO_LOCATION")
	private String geoLocation;

	@Column(name = "MODEL")
	private String model;

	private String height;

	private String width;

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

	public Date getModifiedDate() {
		return modifiedDate;
	}

	public void setModifiedDate(Date modifiedDate) {
		this.modifiedDate = modifiedDate;
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

	public String getGeoLocation() {
		return geoLocation;
	}

	public void setGeoLocation(String geoLocation) {
		this.geoLocation = geoLocation;
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
}
