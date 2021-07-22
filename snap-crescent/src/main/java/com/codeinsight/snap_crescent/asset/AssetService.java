package com.codeinsight.snap_crescent.asset;

import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;

public interface AssetService {
	
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria assetSearchCriteria);
	public void upload(ASSET_TYPE assetType, MultipartFile multipartFiles) throws Exception;
	public UiAsset getById(Long id);
	public byte[] getAssetById(Long id) throws Exception;
	public void update(UiAsset enity) throws Exception;
}
