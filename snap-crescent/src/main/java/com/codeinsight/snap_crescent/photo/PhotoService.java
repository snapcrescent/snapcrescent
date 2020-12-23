package com.codeinsight.snap_crescent.photo;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

public interface PhotoService {

	public void processImages() throws Exception;
	
	public List<Photo> search() throws Exception;
	
	public void upload(MultipartFile[] multipartFiles) throws Exception;
}
