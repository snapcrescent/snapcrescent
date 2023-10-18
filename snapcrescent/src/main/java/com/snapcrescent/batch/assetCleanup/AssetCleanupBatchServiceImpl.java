package com.snapcrescent.batch.assetCleanup;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.AssetRepository;
import com.snapcrescent.asset.AssetSearchCriteria;
import com.snapcrescent.asset.AssetService;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.Constant.BatchStatus;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.metadata.Metadata;
import com.snapcrescent.thumbnail.Thumbnail;
import com.snapcrescent.thumbnail.ThumbnailService;

import lombok.extern.slf4j.Slf4j;


@Service
@Slf4j
public class AssetCleanupBatchServiceImpl extends BaseService implements AssetCleanupBatchService {

	@Autowired
	private AssetCleanupBatchRepository assetImportBatchRepository;
	
	@Autowired
	private AssetRepository assetRepository;

	@Autowired
	private AssetService assetService;
	
	@Autowired
	private FileService fileService;

	@Autowired
	private ThumbnailService thumbnailService;
 	
	@Override
	@Transactional
	public void createBatch() throws Exception {
		AssetCleanupBatch batch = new AssetCleanupBatch();
		batch.setName("Asset Cleanup Batch " + coreService.getAppUsername());
		batch.setBatchStatus(BatchStatus.PENDING.getId());
		assetImportBatchRepository.save(batch);
		
	}

	@Override
	@Transactional
	public AssetCleanupBatch findPendingBatch() {
		return assetImportBatchRepository.findAnyPending();
	}

	@Override
	@Transactional
	public void update(AssetCleanupBatch batch) {
		assetImportBatchRepository.update(batch);
	}

	@Override
	public void process(AssetCleanupBatch batch) throws Exception {
		
		AssetSearchCriteria assetSearchCriteria = new AssetSearchCriteria();
		assetSearchCriteria.setResultPerPage(100);
		assetSearchCriteria.setCreatedByUserId(batch.getCreatedByUserId());

		int totalAssets = assetRepository.count(assetSearchCriteria);

		int numberOfPages = ( totalAssets / assetSearchCriteria.getResultPerPage()) + 1;

		List<Asset> assetsWithoutThumbnailFile = new ArrayList<>();

		for (int pageNumber = 0; pageNumber <= numberOfPages; pageNumber++) {
			
			assetSearchCriteria.setPageNumber(pageNumber);

			List<Asset> assets = assetRepository.search(assetSearchCriteria, false);

			List<Long> assetIdsWithoutFile = new ArrayList<>();

			for (Asset asset : assets) {
				Metadata metadata = asset.getMetadata();
				File assetFile = fileService.getFile(asset.getAssetTypeEnum(), batch.getCreatedByUserId(), metadata.getPath(), metadata.getInternalName());

				if(assetFile.exists() == false) {
					assetIdsWithoutFile.add(asset.getId());
					log.debug(asset.getId() + " : " + assetFile.getName());
				} else {
					Thumbnail thumbnail = asset.getThumbnail();
					File thumbnailFile = fileService.getFile(FILE_TYPE.THUMBNAIL, batch.getCreatedByUserId(), thumbnail.getPath(), thumbnail.getName());
					
					if(thumbnailFile.exists() == false) {
						assetsWithoutThumbnailFile.add(asset);
					}
				}
			}

			assetService.deletePermanently(assetIdsWithoutFile);
		}

		List<Future<Boolean>> processingStatusList = new ArrayList<>(assetsWithoutThumbnailFile.size());
	    
	    for (Asset asset : assetsWithoutThumbnailFile) {
	    	processingStatusList.add(thumbnailService.generateThumbnailAsync(asset));
			
		}
		
        processingStatusList.forEach(item -> {
            try {
            	item.get();
            } catch (Exception e) {
            	log.error("Error processing asset", e);
            }
        });
		
		
	}

	@Override
	@Transactional
	public AssetCleanupBatch findById(Long id) {
		return assetImportBatchRepository.findById(id);
	}


}
