package com.snapcrescent.asset;

import java.io.File;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.metadata.Metadata;

public interface AssetService {
	
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria assetSearchCriteria);
	public List<File> uploadAssets(List<MultipartFile> multipartFiles) throws Exception;
	public Asset processAsset(File temporaryFile) throws Exception;
	public List<Asset> processAssets(List<File> temporaryFiles) throws Exception;
	public Boolean processAsset(AssetType assetType, File temporaryFile, Metadata metadata) throws Exception;
	public UiAsset getById(Long id);
	public byte[] getAssetById(Long id) throws Exception;
	public void updateMetadata(Long id) throws Exception;
	public File migrateAssets(AssetType assetType, File originalFile) throws Exception;
	public void updateActiveFlag(Boolean active, List<Long> ids);
	public void updateFavoriteFlag(Boolean favorite, List<Long> ids);
	public void deletePermanently(List<Long> ids);
	public void deleteAssetPostUserDeletion(Long userId) throws Exception;
	SecuredAssetStreamDTO getAssetDetailsFromToken(String token) throws Exception;
	List<UiAssetTimeline> getAssetTimeline(AssetSearchCriteria searchCriteria);
		
}
