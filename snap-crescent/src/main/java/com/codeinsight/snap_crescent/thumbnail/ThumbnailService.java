package com.codeinsight.snap_crescent.thumbnail;

import java.io.File;

public interface ThumbnailService {

	public Thumbnail generateThumbnail(File file) throws Exception;
}
