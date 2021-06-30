package com.codeinsight.snap_crescent.album;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AlbumServiceImpl implements AlbumService{

	@Autowired
	private AlbumRepository albumRepository;
	
	@Override
	@Transactional
	public List<Album> search(AlbumSearchCriteria albumSearchCriteria) throws Exception {
		return albumRepository.search(albumSearchCriteria);
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
