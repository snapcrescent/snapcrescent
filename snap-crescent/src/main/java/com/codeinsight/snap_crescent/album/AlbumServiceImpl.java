package com.codeinsight.snap_crescent.album;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AlbumServiceImpl implements AlbumService{

	@Autowired
	private AlbumRepository albumRepository;
	
	@Override
	@Transactional
	public Page<Album> search(AlbumSearchCriteria albumSearchCriteria) throws Exception {
		Pageable pageable = PageRequest.of(albumSearchCriteria.getPage(), albumSearchCriteria.getSize());
		return albumRepository.search(pageable);
	}

	@Override
	@Transactional
	public void create(Album album) throws Exception {
		albumRepository.save(album);
		
	}

	@Override
	@Transactional
	public void update(Album album) throws Exception {
		// TODO Auto-generated method stub
		
	}

}
