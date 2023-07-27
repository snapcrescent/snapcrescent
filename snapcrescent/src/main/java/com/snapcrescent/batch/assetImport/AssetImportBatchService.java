package com.snapcrescent.batch.assetImport;

import com.snapcrescent.batch.BatchService;

public interface AssetImportBatchService extends BatchService<AssetImportBatch> {

	public void createBatch(String filesBasePath) throws Exception;	
}
