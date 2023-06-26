package com.snapcrescent.metadata;

import java.io.File;
import java.util.List;

import com.snapcrescent.common.utils.Constant.AssetType;

public interface MetadataService {

	Metadata computeMetaData(AssetType assetType, String originalFilename, File file) throws Exception;
	void recomputeMetaData(AssetType assetType, Metadata metadata, File file) throws Exception;
	Metadata extractMetaDataFromGoogleTakeout(AssetType assetType, File assetFile, File assetJsonFile, File temporaryFile) throws Exception;
	List<UiMetadataTimeline> getMetadataTimeline();
}
