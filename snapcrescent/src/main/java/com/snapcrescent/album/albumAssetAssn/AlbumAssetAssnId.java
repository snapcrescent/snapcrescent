package com.snapcrescent.album.albumAssetAssn;

import java.io.Serializable;

import com.snapcrescent.album.Album;
import com.snapcrescent.asset.Asset;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Embeddable;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Data;

@Embeddable
@Data
public class AlbumAssetAssnId implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 8722410738562768655L;

	@ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.DETACH)
	@JoinColumn(name = "ALBUM_ID")
	private Album album;
	
	@ManyToOne(fetch = FetchType.LAZY, cascade = CascadeType.DETACH, optional=false)
	@JoinColumn(name = "ASSET_ID")
	private Asset asset;
}
