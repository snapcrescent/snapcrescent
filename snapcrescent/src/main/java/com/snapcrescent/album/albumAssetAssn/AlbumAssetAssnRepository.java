package com.snapcrescent.album.albumAssetAssn;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

@Repository
public class AlbumAssetAssnRepository extends BaseRepository<AlbumAssetAssn> {

	public AlbumAssetAssnRepository() {
		super(AlbumAssetAssn.class);
	}
}
