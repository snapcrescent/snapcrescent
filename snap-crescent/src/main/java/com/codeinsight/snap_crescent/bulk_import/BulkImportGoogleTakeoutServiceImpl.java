package com.codeinsight.snap_crescent.bulk_import;

import java.io.File;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.asset.AssetService;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.metadata.Metadata;
import com.codeinsight.snap_crescent.metadata.MetadataRepository;
import com.codeinsight.snap_crescent.metadata.MetadataService;

@Service("google")
public class BulkImportGoogleTakeoutServiceImpl implements BulkImportService {

	@Autowired
	private AssetService assetService;
	
	@Autowired
	private MetadataService metadataService;;

	@Autowired
	private MetadataRepository metadataRepository;

	@Override
	@Transactional
	public void processAsset(AssetType assetType, File asset, BulkImportRequest bulkImportRequest) throws Exception {
		if (!metadataRepository.existByName(asset.getName())) {
			
			File temporaryFile = assetService.migrateAssets(assetType, asset);
			File assetJsonFile  = new File(asset.getAbsolutePath() + ".json"); 
			
			moveFileAfterProcessing(bulkImportRequest, asset);

			if (bulkImportRequest.getExtractMetadataViaInternalService() || assetJsonFile.exists() == false) {
				assetService.processAsset(temporaryFile);
				
				if(assetJsonFile.exists()) {
					moveFileAfterProcessing(bulkImportRequest, assetJsonFile);	
				}
				
			} else {
				Metadata metadata = metadataService.extractMetaDataFromGoogleTakeout(assetType, asset, assetJsonFile, temporaryFile);
				moveFileAfterProcessing(bulkImportRequest, assetJsonFile);
				assetService.processAsset(assetType, temporaryFile, metadata);
			}
		}
	}
}
