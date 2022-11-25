package com.codeinsight.snap_crescent.metadata;

import java.io.File;

import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;

public interface MetadataService {

	public Metadata extractMetaData(AssetType assetType, String originalFilename, File file) throws Exception;
}
