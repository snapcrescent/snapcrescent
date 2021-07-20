package com.codeinsight.snap_crescent.asset;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.common.BaseEntity;
import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;
import com.codeinsight.snap_crescent.metadata.Metadata;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "ASSET")
@Data
@EqualsAndHashCode(callSuper = false)
public class Asset extends BaseEntity {

	private static final long serialVersionUID = -4250460739319965956L;
	
	@Enumerated(EnumType.ORDINAL)
	private ASSET_TYPE assetType;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "THUMBNAIL_ID", nullable = false, insertable = false, updatable = false)
	private Thumbnail thumbnail;

	@Column(name = "THUMBNAIL_ID", nullable = false, insertable = true, updatable = true)
	private Long thumbnailId;

	@OneToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "METADATA_ID", nullable = false, insertable = false, updatable = false)
	private Metadata metadata;

	@Column(name = "METADATA_ID", nullable = false, insertable = true, updatable = true)
	private Long metadataId;
	
	private Boolean favorite = false;
}
