package com.snapcrescent.batchProcess.assetImport;

import org.springframework.stereotype.Repository;

import com.snapcrescent.common.BaseRepository;

@Repository
public class AssetImportBatchProcessRepository extends BaseRepository<AssetImportBatchProcess> {

	public AssetImportBatchProcessRepository() {
		super(AssetImportBatchProcess.class);
	}

}
