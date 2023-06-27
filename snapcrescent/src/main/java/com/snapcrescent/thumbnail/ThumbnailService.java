package com.snapcrescent.thumbnail;

import java.io.File;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.SecuredAssetStreamDTO;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.metadata.Metadata;

public interface ThumbnailService {

	public Thumbnail generateThumbnail(File file, Metadata metadata, AssetType assetType) throws Exception;

	public byte[] getById(Long id);
	public String getFilePathByThumbnailById(Long id) throws Exception;
	SecuredAssetStreamDTO getAssetDetailsFromToken(String token) throws Exception;
	public void regenerateThumbnails(Asset asset);
}
