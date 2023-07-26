package com.snapcrescent.batchProcess.assetImport;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.common.services.BaseService;

import lombok.extern.slf4j.Slf4j;


@Service
@Slf4j
public class AssetImportBatchProcessServiceImpl extends BaseService implements AssetImportBatchProcessService {

	@Autowired
	private AssetImportBatchProcessRepository assetImportBatchProcessRepository;

	@Override
	@Transactional
	public void save(UiAssetImportBatchProcess assetImportBatchProcess) throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	@Transactional
	public void update(UiAssetImportBatchProcess assetImportBatchProcess) throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	@Transactional
	public void delete(Long id) throws Exception {
		// TODO Auto-generated method stub
		
	}
}
