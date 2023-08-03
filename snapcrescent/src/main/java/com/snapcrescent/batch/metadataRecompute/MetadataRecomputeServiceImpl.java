package com.snapcrescent.batch.metadataRecompute;

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
import com.snapcrescent.metadata.MetadataService;

import lombok.extern.slf4j.Slf4j;


@Service
@Slf4j
public class MetadataRecomputeServiceImpl extends BaseService implements MetadataRecomputeService {

	@Autowired
	private MetadataRecomputeRepository metadataRecomputeRepository;
	
	@Autowired
	private AssetRepository assetRepository;
	
	@Autowired
	private MetadataService metadataService;
 	
	@Override
	@Transactional
	public void createBatch(String filesBasePath) throws Exception {
		MetadataRecomputeBatch batch = new MetadataRecomputeBatch();
		batch.setName("Metadata Recompute Batch " + coreService.getAppUsername());
		batch.setBatchStatus(BatchStatus.PENDING.getId());
		metadataRecomputeRepository.save(batch);
		
	}

	@Override
	@Transactional
	public MetadataRecomputeBatch findPendingBatch() {
		return metadataRecomputeRepository.findAnyPending();
	}

	@Override
	@Transactional
	public void update(MetadataRecomputeBatch batch) {
		metadataRecomputeRepository.update(batch);
	}

	@Override
	public void process(MetadataRecomputeBatch batch) throws Exception {
		List<Asset> assets = assetRepository.findAll();
		
	    List<Future<Boolean>> processingStatusList = new ArrayList<>(assets.size());
	    
	    for (Asset asset : assets) {
	    	processingStatusList.add(metadataService.recomputeMetadata(asset));
			
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
	public MetadataRecomputeBatch findById(Long id) {
		return metadataRecomputeRepository.findById(id);
	}


}
