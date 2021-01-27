package com.codeinsight.snap_crescent.photo;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Transient;

import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadata;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "photo")
public class Photo implements Serializable {

	private static final long serialVersionUID = -4250460739319965956L;

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private long id;

	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "THUMBNAIL_ID", nullable = false, insertable = false, updatable = false)
	private Thumbnail thumbnail;

	@Column(name = "THUMBNAIL_ID", nullable = false, insertable = true, updatable = true)
	private Long thumbnailId;

	@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "METADATA_ID", nullable = false, insertable = false, updatable = false)
	private PhotoMetadata metadata;

	@Column(name = "METADATA_ID", nullable = false, insertable = true, updatable = true)
	private Long metaDataId;
	
	@Transient
	private String base64EncodedThumbnail;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public Thumbnail getThumbnail() {
		return thumbnail;
	}

	public void setThumbnail(Thumbnail thumbnail) {
		this.thumbnail = thumbnail;
	}

	public Long getThumbnailId() {
		return thumbnailId;
	}

	public void setThumbnailId(Long thumbnailId) {
		this.thumbnailId = thumbnailId;
	}

	public PhotoMetadata getMetadata() {
		return metadata;
	}

	public void setMetadata(PhotoMetadata metadata) {
		this.metadata = metadata;
	}

	public Long getMetaDataId() {
		return metaDataId;
	}

	public void setMetaDataId(Long metaDataId) {
		this.metaDataId = metaDataId;
	}

	public String getBase64EncodedThumbnail() {
		return base64EncodedThumbnail;
	}

	public void setBase64EncodedThumbnail(String base64EncodedThumbnail) {
		this.base64EncodedThumbnail = base64EncodedThumbnail;
	}
	
}
