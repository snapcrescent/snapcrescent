package com.codeinsight.snap_crescent.common.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import org.apache.commons.io.IOUtils;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.config.EnvironmentProperties;

@Service
public class FileService {

	public byte[] readFileBytes(FILE_TYPE fileType, String fileUniqueName) {
		
		File file = getFile(fileType, fileUniqueName);
		
		byte[] image = null;
		try {
			InputStream in = new FileInputStream(file);
			image = IOUtils.toByteArray(in);
			in.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return image;
	}
	
	public File getFile(FILE_TYPE fileType, String fileUniqueName) {
		
		String basepath = null;
		
		if(fileType == FILE_TYPE.THUMBNAIL) {
			basepath =  EnvironmentProperties.STORAGE_PATH + Constant.THUMBNAIL_FOLDER;
		} else  if(fileType == FILE_TYPE.PHOTO) {
			basepath = EnvironmentProperties.STORAGE_PATH + Constant.PHOTO_FOLDER;
		} else if(fileType == FILE_TYPE.VIDEO) {
			basepath = EnvironmentProperties.STORAGE_PATH + Constant.VIDEO_FOLDER;
		}
		
		return new File(basepath + fileUniqueName);
		
	}

}
