package com.codeinsight.snap_crescent.asset;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.PostLoad;
import javax.persistence.Transient;

import com.codeinsight.snap_crescent.common.BaseEntity;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.metadata.Metadata;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class Asset extends BaseEntity {

	private static final long serialVersionUID = -4250460739319965956L;
	
	@Basic
	private Integer assetType;
	
	@Transient
    private AssetType assetTypeEnum;

	@OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
	@JoinColumn(name = "THUMBNAIL_ID", nullable = false, insertable = false, updatable = false)
	private Thumbnail thumbnail;

	@Column(name = "THUMBNAIL_ID", nullable = false, insertable = true, updatable = true)
	private Long thumbnailId;

	@OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
	@JoinColumn(name = "METADATA_ID", nullable = false, insertable = false, updatable = false)
	private Metadata metadata;

	@Column(name = "METADATA_ID", nullable = false, insertable = true, updatable = true)
	private Long metadataId;
	
	private Boolean favorite = false;
	
	@PostLoad
    void fillTransient() {
		if(assetType > 0) {
			this.assetTypeEnum = AssetType.findById(assetType);
		}
	}
}
