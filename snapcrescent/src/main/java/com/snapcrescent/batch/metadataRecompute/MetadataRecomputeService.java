package com.snapcrescent.batch.metadataRecompute;

import com.snapcrescent.batch.BatchService;

public interface MetadataRecomputeService extends BatchService<MetadataRecomputeBatch> {

	public void createBatch(String filesBasePath) throws Exception;	
}
