package com.snapcrescent.album.albumAssetAssn;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import lombok.Data;

@Entity
@Data
public class AlbumAssetAssn {
	
	@EmbeddedId
	private AlbumAssetAssnId id;

}
