package com.snapcrescent.metadata;

import java.io.File;
import java.util.concurrent.Future;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.common.utils.Constant.AssetType;

public interface MetadataService {

	Metadata createMetadataEntity(File temporaryFile) throws Exception;
	Metadata extractMetaDataFromGoogleTakeout(AssetType assetType, File assetFile, File assetJsonFile, File temporaryFile) throws Exception;
	Future<Boolean> recomputeMetadata(Asset asset);
	
}
