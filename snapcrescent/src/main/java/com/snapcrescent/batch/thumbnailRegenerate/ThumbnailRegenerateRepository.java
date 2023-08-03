package com.snapcrescent.batch.thumbnailRegenerate;

import org.springframework.stereotype.Repository;

import com.snapcrescent.batch.BatchRepository;

@Repository
public class ThumbnailRegenerateRepository extends BatchRepository<ThumbnailRegenerateBatch> {

	public ThumbnailRegenerateRepository() {
		super(ThumbnailRegenerateBatch.class);
	}

}
