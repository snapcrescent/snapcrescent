package com.codeinsight.snap_crescent.album;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class AlbumRepository extends BaseRepository<Album> {

	public AlbumRepository() {
		super(Album.class);
	}

	public List<Album> search(AlbumSearchCriteria albumSearchCriteria) {
		return null;
	}
}
