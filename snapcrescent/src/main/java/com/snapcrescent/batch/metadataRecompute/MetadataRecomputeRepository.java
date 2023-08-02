package com.snapcrescent.batch.metadataRecompute;

import org.springframework.stereotype.Repository;

import com.snapcrescent.batch.BatchRepository;

@Repository
public class MetadataRecomputeRepository extends BatchRepository<MetadataRecomputeBatch> {

	public MetadataRecomputeRepository() {
		super(MetadataRecomputeBatch.class);
	}

}
