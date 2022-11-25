package com.codeinsight.snap_crescent.common.utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;

@Service
public class FileService {
	
	@Value("${sc.storage.path}")
	private String STORAGE_PATH;
	
	
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
	
	public byte[] readBufferedFileBytes(FILE_TYPE fileType,String path, String fileName, int start, int end) throws FileNotFoundException, IOException {
		
		
		File file = getFile(fileType, path, fileName);
		
		try (InputStream inputStream = new FileInputStream(file);
             ByteArrayOutputStream bufferedOutputStream = new ByteArrayOutputStream()) {
            byte[] data = new byte[10 * 1024 * 1024];
            int nRead;
            while ((nRead = inputStream.read(data, 0, data.length)) != -1) {
                bufferedOutputStream.write(data, 0, nRead);
            }
            bufferedOutputStream.flush();
            byte[] result = new byte[(int) (end - start) + 1];
            System.arraycopy(bufferedOutputStream.toByteArray(), (int) start, result, 0, result.length);
            return result;
        }
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
			basepath =  STORAGE_PATH + Constant.THUMBNAIL_FOLDER;
		} else  if(fileType == FILE_TYPE.PHOTO) {
			basepath = STORAGE_PATH + Constant.PHOTO_FOLDER;
		} else if(fileType == FILE_TYPE.VIDEO) {
			basepath = STORAGE_PATH + Constant.VIDEO_FOLDER;
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
