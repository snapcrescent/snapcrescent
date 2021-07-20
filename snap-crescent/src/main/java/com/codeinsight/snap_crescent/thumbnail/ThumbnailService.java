package com.codeinsight.snap_crescent.thumbnail;

import java.io.File;

import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;
import com.codeinsight.snap_crescent.metadata.Metadata;

public interface ThumbnailService {

	public Thumbnail generateThumbnail(File file, Metadata metadata, ASSET_TYPE assetType) throws Exception;

	public byte[] getById(Long id);
}
