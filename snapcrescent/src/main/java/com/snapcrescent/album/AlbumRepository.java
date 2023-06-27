package com.snapcrescent.album;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

@Repository
public class AlbumRepository extends BaseRepository<Album> {

	public AlbumRepository() {
		super(Album.class);
	}

	public List<Album> search(AlbumSearchCriteria albumSearchCriteria) {
		return null;
	}
}
