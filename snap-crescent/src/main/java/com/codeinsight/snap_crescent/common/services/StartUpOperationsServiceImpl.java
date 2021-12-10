package com.codeinsight.snap_crescent.common.services;

import java.io.File;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant;
import com.codeinsight.snap_crescent.common.utils.FileService;

@Service
public class StartUpOperationsServiceImpl extends BaseService implements StartUpOperationsService {

	@Autowired
	private FileService fileService;
	
	@Override
	@Transactional
	public void performPostStartUpOperations() {
		try {
			createAssetFolders();
			
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	
	private void createAssetFolders() {

		// Create Folders for Storing Images, Videos and Thumbnails
		for (FILE_TYPE fileType : FILE_TYPE.values()) {
			File coreDirectory = new File(fileService.getBasePath(fileType));
			if (!coreDirectory.exists()) {
				coreDirectory.mkdir();
			}
			
			if(fileType == FILE_TYPE.THUMBNAIL) {
				continue;
			}
			
			//Create folders for storing uploaded Images, Videos, it will be moved to folders after extracting meta-data
			File tempDirectory = new File(fileService.getBasePath(fileType) + Constant.UNPROCESSED_ASSET_FOLDER);
			if (!tempDirectory.exists()) {
				tempDirectory.mkdir();
			}
		}
	}
}
