package com.codeinsight.snap_crescent.photo;

import java.util.ArrayList;

import org.springframework.data.domain.Page;
import org.springframework.web.multipart.MultipartFile;

public interface PhotoService {
	
	public Page<Photo> search(PhotoSearchCriteria photoSearchCriteria) throws Exception;
	
	public void upload(ArrayList<MultipartFile> multipartFiles) throws Exception;
	
	public byte[] getById(Long id) throws Exception;
	
	public void like(Long id) throws Exception;
}
