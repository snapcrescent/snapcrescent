package com.snapcrescent.batch.assetImport;

import java.io.File;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.AssetService;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.Constant.BatchStatus;

import lombok.extern.slf4j.Slf4j;


@Service
@Slf4j
public class AssetImportBatchServiceImpl extends BaseService implements AssetImportBatchService {

	@Autowired
	private AssetImportBatchRepository assetImportBatchRepository;
	
	@Autowired
	private AssetService assetService;
	
	@Autowired
	private FileService fileService;
 	
	@Override
	@Transactional
	public void createBatch(String filesBasePath) throws Exception {
		AssetImportBatch batch = new AssetImportBatch();
		batch.setFilesBasePath(filesBasePath);
		batch.setName("Asset Import Batch " + coreService.getAppUsername());
		batch.setBatchStatus(BatchStatus.PENDING.getId());
		assetImportBatchRepository.save(batch);
		
	}

	@Override
	@Transactional
	public AssetImportBatch findPendingBatch() {
		return assetImportBatchRepository.findAnyPending();
	}

	@Override
	@Transactional
	public void update(AssetImportBatch batch) {
		assetImportBatchRepository.update(batch);
	}

	@Override
	public void process(AssetImportBatch batch) throws Exception {
		String filesBasePath = batch.getFilesBasePath();
		
		String directoryPath = fileService.getBasePath(batch.getCreatedByUserId()) + "/" + filesBasePath + "/";
		
		Set<String> fileSet = new HashSet<>();
	    try (DirectoryStream<Path> stream = Files.newDirectoryStream(Paths.get(directoryPath))) {
	        for (Path path : stream) {
	            if (!Files.isDirectory(path)) {
	                fileSet.add(path.getFileName().toString());
	            }
	        }
	    }
	    
	    List<Future<Boolean>> processingStatusList = new ArrayList<>(fileSet.size());
	    
	    for (String fileName : fileSet) {
			File temporaryFile = new File(directoryPath + fileName);
			
			if(temporaryFile.exists()) {
				processingStatusList.add(assetService.processAsset(temporaryFile, batch.getCreatedByUserId()));
			}
		}
		
        processingStatusList.forEach(item -> {
            try {
            	item.get();
            } catch (Exception e) {
            	log.error("Error processing asset", e);
            }
        });
        
        
        fileService.removeFile(directoryPath);
        
	}

	@Override
	@Transactional
	public AssetImportBatch findById(Long id) {
		return assetImportBatchRepository.findById(id);
	}


}
