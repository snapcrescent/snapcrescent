package com.codeinsight.snap_crescent.common.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;

@Service
public class FileService {

	@Value("${thumbnail.output.path}")
	private String THUMBNAIL_PATH;
	
	@Value("${photo.path}")
	private String PHOTO_PATH;

	public byte[] readFileBytes(FILE_TYPE fileType, String fileUniqueName) {
		
		String basepath = null;
		
		if(fileType == FILE_TYPE.THUMBNAIL) {
			basepath = THUMBNAIL_PATH;
		} if(fileType == FILE_TYPE.PHOTO) {
			basepath = PHOTO_PATH;
		}
		
		File file = new File(basepath + fileUniqueName);
		byte[] image = null;
		try {
			InputStream in = new FileInputStream(file);
			image = IOUtils.toByteArray(in);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return image;
	}

}
