package com.codeinsight.snap_crescent.video;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.common.BaseEntity;
import com.codeinsight.snap_crescent.videoMetadata.VideoMetadata;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "VIDEO")
@Data
@EqualsAndHashCode(callSuper = false)
public class Video extends BaseEntity {

	private static final long serialVersionUID = -4250460739319965956L;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "THUMBNAIL_ID", nullable = false, insertable = false, updatable = false)
	private Thumbnail thumbnail;

	@Column(name = "THUMBNAIL_ID", nullable = false, insertable = true, updatable = true)
	private Long thumbnailId;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "VIDEO_METADATA_ID", nullable = false, insertable = false, updatable = false)
	private VideoMetadata videoMetadata;

	@Column(name = "VIDEO_METADATA_ID", nullable = false, insertable = true, updatable = true)
	private Long videoMetadataId;
	
	private Boolean favorite;
}
