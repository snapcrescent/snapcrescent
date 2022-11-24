package com.codeinsight.snap_crescent.bulk_import;

import java.io.File;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.UUID;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.asset.AssetService;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.metadata.MetadataRepository;
import com.codeinsight.snap_crescent.sync_info.SyncInfoService;

@Service
public class BulkImportServiceImpl implements BulkImportService {

	@Autowired
	private AssetService assetService;

	@Autowired
	private SyncInfoService syncInfoService;

	@Autowired
	private MetadataRepository metadataRepository;

	@Override
	@Transactional
	public void bulkImportFromDirectory(String sourceDirectory, String destinationDirectory) throws Exception {

		File baseDirectoryPath = new File(sourceDirectory);

		// List of all files and directories
		String fileOrFolders[] = baseDirectoryPath.list();
		

		for (String assetFileString : fileOrFolders) {

			File asset = new File(sourceDirectory + "/" + assetFileString);

			if (asset.isDirectory()) {
				this.bulkImportFromDirectory(asset.getAbsolutePath(), destinationDirectory);
			} else {

				String assetName = assetFileString.substring(0, assetFileString.lastIndexOf("."));
				String extension = assetFileString.substring(assetFileString.lastIndexOf(".") + 1, assetFileString.length());

				AssetType assetType = null;
				if (extension.equalsIgnoreCase("gif") || extension.equalsIgnoreCase("jpg")
						|| extension.equalsIgnoreCase("png") || extension.equalsIgnoreCase("raw")
						|| extension.equalsIgnoreCase("heif")) {
					assetType = AssetType.PHOTO;
				} else if (extension.equalsIgnoreCase("mp4") || extension.equalsIgnoreCase("mov")) {
					assetType = AssetType.VIDEO;
				}

				if (assetType != null) {
					File temporaryFile;
					if (!metadataRepository.existByName(assetFileString)) {
						temporaryFile = assetService.migrateAssets(assetType, asset);
						try {
							Files.move(Paths.get(asset.getAbsolutePath()),Paths.get(destinationDirectory + "/" + assetFileString));	
						} catch (FileAlreadyExistsException e) {
							Files.move(Paths.get(asset.getAbsolutePath()),Paths.get(destinationDirectory + "/" + assetName + UUID.randomUUID().toString() + "." + extension));
						}
						
						assetService.processAsset(assetType, temporaryFile);
					}

				}
				

			}

		}
		
		syncInfoService.save();

	}
}
