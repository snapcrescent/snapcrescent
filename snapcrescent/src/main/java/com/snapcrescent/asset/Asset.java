package com.snapcrescent.asset;

import jakarta.persistence.Basic;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PostLoad;
import jakarta.persistence.Transient;

import java.util.List;

import com.snapcrescent.album.Album;
import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.metadata.Metadata;
import com.snapcrescent.thumbnail.Thumbnail;

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
	
	@ManyToMany(fetch = FetchType.LAZY, cascade = CascadeType.DETACH)
	@JoinTable(name = "ALBUM_ASSET_ASSN", joinColumns = {
			@JoinColumn(name = "ASSET_ID", updatable = false) }, inverseJoinColumns = {
					@JoinColumn(name = "ALBUM_ID", updatable = false) })
	private List<Album> albums;
	
	@PostLoad
    void fillTransient() {
		if(assetType > 0) {
			this.assetTypeEnum = AssetType.findById(assetType);
		}
	}
}
