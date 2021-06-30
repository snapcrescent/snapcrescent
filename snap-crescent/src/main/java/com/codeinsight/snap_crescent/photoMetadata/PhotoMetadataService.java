package com.codeinsight.snap_crescent.photoMetadata;

import java.io.File;

public interface PhotoMetadataService {

	public PhotoMetadata extractMetaData(String originalFilename, File file) throws Exception;
}
