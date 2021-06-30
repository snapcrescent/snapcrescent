package com.codeinsight.snap_crescent.photo;

import java.util.ArrayList;

import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

public interface PhotoService {
	
	public BaseResponseBean<Long, UiPhoto> search(PhotoSearchCriteria photoSearchCriteria);
	
	public void upload(ArrayList<MultipartFile> multipartFiles) throws Exception;
	
	public UiPhoto getById(Long id);

	public byte[] getImageById(Long id) throws Exception;
	
	public void like(Long id) throws Exception;
}
