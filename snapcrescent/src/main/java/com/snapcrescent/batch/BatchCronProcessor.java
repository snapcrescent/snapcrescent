package com.snapcrescent.batch;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.snapcrescent.batch.assetImport.AssetImportBatch;
import com.snapcrescent.batch.assetImport.AssetImportBatchService;
import com.snapcrescent.batch.metadataRecompute.MetadataRecomputeBatch;
import com.snapcrescent.batch.metadataRecompute.MetadataRecomputeService;
import com.snapcrescent.common.utils.Constant.BatchStatus;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class BatchCronProcessor {

	@Autowired
	private AssetImportBatchService assetImportBatchService;
	
	@Autowired
	private MetadataRecomputeService metadataRecomputeService;

	// Execute after 10 seconds

	@Async
	@Scheduled(cron = "*/10 * * * * *")
	public void processAssetImportBatch() {
		
		
		AssetImportBatch batch = assetImportBatchService.findPendingBatch();

		if(batch != null) {
			batch.setBatchStatus(BatchStatus.IN_PROGRESS.getId());
			batch.setStartDateTime(new Date());
			assetImportBatchService.update(batch);
			
			batch = assetImportBatchService.findById(batch.getId());
			
			try {
				assetImportBatchService.process(batch);	
			} catch (Exception e) {
				log.error("Error processing asset import batch", e);
			}
			

			batch.setBatchStatus(BatchStatus.COMPLETED.getId());
			batch.setEndDateTime(new Date());

			assetImportBatchService.update(batch);
		}
	}
	
	@Async
	@Scheduled(cron = "*/10 * * * * *")
	public void processMetadataRecomputeBatch() {
		
		
		MetadataRecomputeBatch batch = metadataRecomputeService.findPendingBatch();

		if(batch != null) {
			batch.setBatchStatus(BatchStatus.IN_PROGRESS.getId());
			batch.setStartDateTime(new Date());
			metadataRecomputeService.update(batch);
			
			batch = metadataRecomputeService.findById(batch.getId());
			
			try {
				metadataRecomputeService.process(batch);	
			} catch (Exception e) {
				log.error("Error processing asset import batch", e);
			}
			

			batch.setBatchStatus(BatchStatus.COMPLETED.getId());
			batch.setEndDateTime(new Date());

			metadataRecomputeService.update(batch);
		}
	}
}
