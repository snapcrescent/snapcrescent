package com.snapcrescent.batch.assetCleanup;

import org.springframework.stereotype.Repository;

import com.snapcrescent.batch.BatchRepository;

@Repository
public class AssetCleanupBatchRepository extends BatchRepository<AssetCleanupBatch> {

	public AssetCleanupBatchRepository() {
		super(AssetCleanupBatch.class);
	}

}
