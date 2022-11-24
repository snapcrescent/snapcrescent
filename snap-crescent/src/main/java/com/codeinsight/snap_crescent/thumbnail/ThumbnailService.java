package com.codeinsight.snap_crescent.thumbnail;

import java.io.File;

import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.metadata.Metadata;

public interface ThumbnailService {

	public Thumbnail generateThumbnail(File file, Metadata metadata, AssetType assetType) throws Exception;

	public byte[] getById(Long id);
}
