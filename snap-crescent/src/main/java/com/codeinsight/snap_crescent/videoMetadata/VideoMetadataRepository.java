package com.codeinsight.snap_crescent.videoMetadata;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class VideoMetadataRepository extends BaseRepository<VideoMetadata>{
	
	public VideoMetadataRepository() {
		super(VideoMetadata.class);
	}

	public boolean existsByName(String name) {
		return true;
	}
}
