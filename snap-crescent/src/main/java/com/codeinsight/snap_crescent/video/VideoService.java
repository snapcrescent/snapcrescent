package com.codeinsight.snap_crescent.video;

import java.io.File;
import java.util.ArrayList;

import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

public interface VideoService {
	
	public BaseResponseBean<Long, UiVideo> search(VideoSearchCriteria videoSearchCriteria);
	public void upload(ArrayList<MultipartFile> multipartFiles) throws Exception;
	public UiVideo getById(Long id);
	public File getVideoById(Long id) throws Exception;
	public void update(UiVideo enity) throws Exception;
}
