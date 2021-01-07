package com.codeinsight.snap_crescent.thumbnail;

import java.io.File;

import com.codeinsight.snap_crescent.photoMetadata.PhotoMetadata;

public interface ThumbnailService {

	public Thumbnail generateThumbnail(File file, PhotoMetadata photoMetadata) throws Exception;

	public byte[] getById(Long id);
}
