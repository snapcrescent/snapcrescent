package com.codeinsight.snap_crescent.photo;

import java.util.ArrayList;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

public interface PhotoService {
	
	public List<Photo> search() throws Exception;
	
	public void upload(ArrayList<MultipartFile> multipartFiles) throws Exception;
}
