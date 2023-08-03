package com.snapcrescent.batch.thumbnailRegenerate;

import com.snapcrescent.batch.BatchService;

public interface ThumbnailRegenerateService extends BatchService<ThumbnailRegenerateBatch> {

	public void createBatch(String filesBasePath) throws Exception;	
}
