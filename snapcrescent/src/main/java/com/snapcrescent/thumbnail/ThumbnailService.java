package com.snapcrescent.thumbnail;

import java.io.IOException;
import java.util.concurrent.Future;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.SecuredAssetStreamDTO;
import com.snapcrescent.metadata.Metadata;

public interface ThumbnailService {

	public Boolean generateThumbnail(Asset asset);

	public Thumbnail createThumbnailEntity(Metadata metadata) throws Exception;

	public String getFilePathByThumbnailById(Long id) throws Exception;

	SecuredAssetStreamDTO getAssetDetailsFromToken(String token) throws Exception;

	Future<Boolean> generateThumbnailAsync(Asset asset);

	public void updateThumbnailPostAssetDeletion(Asset asset) throws IOException;
}
