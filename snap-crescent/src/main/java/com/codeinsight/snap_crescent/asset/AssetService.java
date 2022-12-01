package com.codeinsight.snap_crescent.asset;

import java.io.File;
import java.util.List;
import java.util.concurrent.Future;

import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.metadata.Metadata;

public interface AssetService {
	
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria assetSearchCriteria);
	public List<File> uploadAssets(AssetType assetType, List<MultipartFile> multipartFiles) throws Exception;
	public Future<Boolean> processAsset(AssetType assetType, File temporaryFile) throws Exception;
	Future<Boolean> processAsset(AssetType assetType, File temporaryFile, Metadata metadata) throws Exception;
	public UiAsset getById(Long id);
	public byte[] getAssetById(Long id) throws Exception;
	public String getFilePathByAssetById(Long id) throws Exception;
	public void updateMetadata(Long id) throws Exception;
	File migrateAssets(AssetType assetType, File originalFile) throws Exception;
	public void markActive(List<Long> ids);
	public void markInactive(List<Long> ids);
	public void deletePermanently(List<Long> ids);
		
}
