package com.codeinsight.snap_crescent.videoMetadata;

import java.io.File;

public interface VideoMetadataService {

	public VideoMetadata extractMetaData(String originalFilename, File file) throws Exception;
}
