package com.snapcrescent.batch.assetImport;

import org.springframework.stereotype.Repository;

import com.snapcrescent.batch.BatchRepository;

@Repository
public class AssetImportBatchRepository extends BatchRepository<AssetImportBatch> {

	public AssetImportBatchRepository() {
		super(AssetImportBatch.class);
	}

}
