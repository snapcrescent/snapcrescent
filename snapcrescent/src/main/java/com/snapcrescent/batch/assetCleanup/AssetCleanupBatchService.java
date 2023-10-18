package com.snapcrescent.batch.assetCleanup;

import com.snapcrescent.batch.BatchService;

public interface AssetCleanupBatchService extends BatchService<AssetCleanupBatch> {

	public void createBatch() throws Exception;	
}
