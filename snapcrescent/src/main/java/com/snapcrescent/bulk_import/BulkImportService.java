package com.snapcrescent.bulk_import;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.UUID;

import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.Constant.AssetType;

public interface BulkImportService {
	
	default void bulkImport(BulkImportRequest  bulkImportRequest) throws Exception {

		File baseDirectoryPath = new File(bulkImportRequest.getSourceDirectory());

		// List of all files and directories
		String fileOrFolders[] = baseDirectoryPath.list();
		
		for (String assetFileOrFolderName : fileOrFolders) {

			File asset = new File(bulkImportRequest.getSourceDirectory() + "/" + assetFileOrFolderName);

			if (asset.isDirectory() && bulkImportRequest.getImportRecursively()) {
				BulkImportRequest  bulkImportRecusiveRequest = new BulkImportRequest(asset.getAbsolutePath(), bulkImportRequest.getDestinationDirectory(), bulkImportRequest.getExtractMetadataViaInternalService(), bulkImportRequest.getImportRecursively());
				this.bulkImport(bulkImportRecusiveRequest);
			} else {

				AssetType assetType = FileService.getAssetType(asset.getName());

				if (assetType != null) {
					processAsset(assetType, asset, bulkImportRequest);
				}
			}
		}

	}
	
	
	
	default void moveFileAfterProcessing(BulkImportRequest  bulkImportRequest, File asset) throws IOException
    {
		String fileNamePlusExtension = asset.getName();
		String assetName = fileNamePlusExtension.substring(0, fileNamePlusExtension.lastIndexOf("."));
		String extension = fileNamePlusExtension.substring(fileNamePlusExtension.lastIndexOf(".") + 1, fileNamePlusExtension.length());
		
		if(bulkImportRequest.getDestinationDirectory() != null) {
			
			File destinationDirectory = new File(bulkImportRequest.getDestinationDirectory());
			
			if (!destinationDirectory.exists()) {
				destinationDirectory.mkdir();
			}
			
			try {
				Files.move(Paths.get(asset.getAbsolutePath()),Paths.get(bulkImportRequest.getDestinationDirectory() + "/" + fileNamePlusExtension));	
			} catch (FileAlreadyExistsException e) {
				Files.move(Paths.get(asset.getAbsolutePath()),Paths.get(bulkImportRequest.getDestinationDirectory() + "/" + assetName + UUID.randomUUID().toString() + "." + extension));
			}	
		}
		
    }
	
	public void processAsset(AssetType assetType, File asset, BulkImportRequest  bulkImportRequest) throws Exception;

}
