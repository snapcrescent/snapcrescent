package com.codeinsight.snap_crescent.metadata;

import java.io.File;

public interface MetadataService {

	public Metadata extractMetaData(String originalFilename, File file) throws Exception;
}
