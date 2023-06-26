package com.snapcrescent.common.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.commons.io.IOUtils;
import org.springframework.stereotype.Service;

import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.config.EnvironmentProperties;

@Service
public class FileService {
	
	public static AssetType getAssetType(String assetName)
    {
		String extension = assetName.substring(assetName.lastIndexOf(".") + 1, assetName.length());
		
		AssetType assetType = null;
		if (extension.equalsIgnoreCase("gif") || extension.equalsIgnoreCase("jpg")
				|| extension.equalsIgnoreCase("png") || extension.equalsIgnoreCase("raw")
				|| extension.equalsIgnoreCase("heif")) {
			assetType = AssetType.PHOTO;
		} else if (extension.equalsIgnoreCase("mp4") || extension.equalsIgnoreCase("mov")) {
			assetType = AssetType.VIDEO;
		}
		
		return assetType;
		
    }
	
	public byte[] readFileBytes(FILE_TYPE fileType,String path, String fileName) {
		
		File file = getFile(fileType, path, fileName);
		
		byte[] fileBytes = null;
		try {
			InputStream in = new FileInputStream(file);
			fileBytes = IOUtils.toByteArray(in);
			in.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return fileBytes;
	}
	
	public long getFileSize(FILE_TYPE fileType,String path, String fileName) throws IOException {
		return Files.size(Paths.get(getBasePath(fileType) + path + fileName));
	}
	
	public File getFile(FILE_TYPE fileType, String path, String fileName) {
		return new File(getBasePath(fileType) + path + fileName);
	}
	
	public InputStream getFileInputStream(FILE_TYPE fileType, String path, String fileName) throws IOException {
		return Files.newInputStream(Paths.get(getBasePath(fileType) + path + fileName));
	}
	
	public void removeFile(FILE_TYPE fileType,String path, String fileName) throws IOException {
		Files.delete(Paths.get(getBasePath(fileType) + path + fileName));
	}
	
	public String getBasePath(AssetType assetType) {
		
		String basepath = null;
		
		if(assetType == AssetType.PHOTO) {
			basepath =  getBasePath(FILE_TYPE.PHOTO);
		} else  if(assetType == AssetType.VIDEO) {
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
