package com.snapcrescent.batch.thumbnailRegenerate;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.AssetRepository;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant.BatchStatus;
import com.snapcrescent.thumbnail.ThumbnailService;

import lombok.extern.slf4j.Slf4j;


@Service
@Slf4j
public class ThumbnailRegenerateServiceImpl extends BaseService implements ThumbnailRegenerateService {

	@Autowired
	private ThumbnailRegenerateRepository thumbnailRegenerateRepository;
	
	@Autowired
	private AssetRepository assetRepository;
	
	@Autowired
	private ThumbnailService thumbnailService;
 	
	@Override
	@Transactional
	public void createBatch(String filesBasePath) throws Exception {
		ThumbnailRegenerateBatch batch = new ThumbnailRegenerateBatch();
		batch.setName("Thumbnail Renerate Batch " + coreService.getAppUsername());
		batch.setBatchStatus(BatchStatus.PENDING.getId());
		thumbnailRegenerateRepository.save(batch);
		
	}

	@Override
	@Transactional
	public ThumbnailRegenerateBatch findPendingBatch() {
		return thumbnailRegenerateRepository.findAnyPending();
	}

	@Override
	@Transactional
	public void update(ThumbnailRegenerateBatch batch) {
		thumbnailRegenerateRepository.update(batch);
	}

	@Override
	public void process(ThumbnailRegenerateBatch batch) throws Exception {
		List<Asset> assets = assetRepository.findAll();
		
	    List<Future<Boolean>> processingStatusList = new ArrayList<>(assets.size());
	    
	    for (Asset asset : assets) {
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
	public ThumbnailRegenerateBatch findById(Long id) {
		return thumbnailRegenerateRepository.findById(id);
	}


}
