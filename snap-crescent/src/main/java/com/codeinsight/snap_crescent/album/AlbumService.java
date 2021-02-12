package com.codeinsight.snap_crescent.album;

import org.springframework.data.domain.Page;

public interface AlbumService {

	public Page<Album> search(AlbumSearchCriteria albumSearchCriteria) throws Exception;

	public void create(Album album) throws Exception;

	public void update(Album album) throws Exception;

}
