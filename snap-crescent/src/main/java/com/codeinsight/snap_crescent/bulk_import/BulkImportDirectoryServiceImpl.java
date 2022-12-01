package com.codeinsight.snap_crescent.bulk_import;

import java.io.File;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.asset.AssetService;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.metadata.MetadataRepository;

@Service("directory")
public class BulkImportDirectoryServiceImpl implements BulkImportService {

	@Autowired
	private AssetService assetService;

	@Autowired
	private MetadataRepository metadataRepository;

	@Override
	@Transactional
	public void processAsset(AssetType assetType, File asset, BulkImportRequest  bulkImportRequest) throws Exception {
		if (!metadataRepository.existByName(asset.getName())) {
			File temporaryFile = assetService.migrateAssets(assetType, asset);
			moveFileAfterProcessing(bulkImportRequest, asset);
			assetService.processAsset(assetType, temporaryFile);
			}
		}
	}

	