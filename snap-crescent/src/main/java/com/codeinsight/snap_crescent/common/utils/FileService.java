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
		
		String basepath = null;
		
		if(fileType == FILE_TYPE.THUMBNAIL) {
			basepath =  EnvironmentProperties.STORAGE_PATH + Constant.THUMBNAIL_FOLDER;
		} if(fileType == FILE_TYPE.PHOTO) {
			basepath = EnvironmentProperties.STORAGE_PATH + Constant.PHOTO_FOLDER;
		}
		
		File file = new File(basepath + fileUniqueName);
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

}
