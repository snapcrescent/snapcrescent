package com.snapcrescent.batchProcess.assetImport;

public interface AssetImportBatchProcessService {

	public void save(UiAssetImportBatchProcess assetImportBatchProcess) throws Exception;
	public void update(UiAssetImportBatchProcess assetImportBatchProcess) throws Exception;
	public void delete(Long id) throws Exception;
	
}
