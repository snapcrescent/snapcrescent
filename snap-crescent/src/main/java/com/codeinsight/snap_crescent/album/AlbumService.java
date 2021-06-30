package com.codeinsight.snap_crescent.album;

import java.util.List;

public interface AlbumService {

	public List<Album> search(AlbumSearchCriteria albumSearchCriteria) throws Exception;
	public void create(Album album) throws Exception;
	public void update(Album album) throws Exception;

}
