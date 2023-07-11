package com.snapcrescent.bulk_import;

import java.io.File;

import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.snapcrescent.asset.AssetService;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.metadata.MetadataRepository;

@Service("directory")
public class BulkImportDirectoryServiceImpl extends BaseService implements BulkImportService {

	@Autowired
	private AssetService assetService;

	@Autowired
	private MetadataRepository metadataRepository;

	@Override
	@Transactional
	public void processAsset(AssetType assetType, File asset, BulkImportRequest  bulkImportRequest) throws Exception {
		if (!metadataRepository.existByName(asset.getName(), coreService.getAppUserId())) {
			File temporaryFile = assetService.migrateAssets(assetType, asset);
			moveFileAfterProcessing(bulkImportRequest, asset);
			assetService.processAsset(temporaryFile);
			}
		}
	}

	