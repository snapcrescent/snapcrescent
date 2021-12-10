package com.codeinsight.snap_crescent.common.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.commons.io.IOUtils;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.config.EnvironmentProperties;

@Service
public class FileService {
	
	public byte[] readFileBytes(FILE_TYPE fileType,String path, String fileName) {
		
		File file = getFile(fileType, path, fileName);
		
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
	
	public File getFile(FILE_TYPE fileType, String path, String fileName) {
		return new File(getBasePath(fileType) + path + fileName);
		
	}
	
	public void removeFile(FILE_TYPE fileType,String path, String fileName) throws IOException {
		Files.delete(Paths.get(getBasePath(fileType) + path + fileName));
	}
	
	public String getBasePath(ASSET_TYPE assetType) {
		
		String basepath = null;
		
		if(assetType == ASSET_TYPE.PHOTO) {
			basepath =  getBasePath(FILE_TYPE.PHOTO);
		} else  if(assetType == ASSET_TYPE.VIDEO) {
			basepath =  getBasePath(FILE_TYPE.VIDEO);
		} 
		
		return basepath;
	}
	
	public String getBasePath(FILE_TYPE fileType) {
		
		String basepath = null;
		
		if(fileType == FILE_TYPE.THUMBNAIL) {
			basepath =  EnvironmentProperties.STORAGE_PATH + Constant.THUMBNAIL_FOLDER;
		} else  if(fileType == FILE_TYPE.PHOTO) {
			basepath = EnvironmentProperties.STORAGE_PATH + Constant.PHOTO_FOLDER;
		} else if(fileType == FILE_TYPE.VIDEO) {
			basepath = EnvironmentProperties.STORAGE_PATH + Constant.VIDEO_FOLDER;
		}
		return basepath;
	}
	
	public boolean mkdirs(String directoryPath) {
		File directory = new File(directoryPath);
		
		if(!directory.exists()) {
			directory.mkdirs();
		}
		
		return true;
	}

}
