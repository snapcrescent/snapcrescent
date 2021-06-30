package com.codeinsight.snap_crescent.photoMetadata;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class PhotoMetadataRepository extends BaseRepository<PhotoMetadata>{
	
	public PhotoMetadataRepository() {
		super(PhotoMetadata.class);
	}

	public boolean existsByName(String name) {
		return true;
	}
}
