package com.codeinsight.snap_crescent.asset;

import java.io.File;
import java.util.List;
import java.util.concurrent.Future;

import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;

public interface AssetService {
	
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria assetSearchCriteria);
	public List<File> uploadAssets(ASSET_TYPE assetType, List<MultipartFile> multipartFiles) throws Exception;
	public Future<Boolean> processAsset(ASSET_TYPE assetType, File temporaryFile) throws Exception;
	public UiAsset getById(Long id);
	public byte[] getAssetById(Long id) throws Exception;
	public void update(UiAsset enity) throws Exception;	
}
