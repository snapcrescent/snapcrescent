package com.codeinsight.snap_crescent.metadata;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class MetadataRepository extends BaseRepository<Metadata>{
	
	public MetadataRepository() {
		super(Metadata.class);
	}

	public boolean existsByName(String name) {
		return false;
	}
}
