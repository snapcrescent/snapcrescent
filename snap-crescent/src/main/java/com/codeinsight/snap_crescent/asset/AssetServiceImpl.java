package com.codeinsight.snap_crescent.asset;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.appConfig.AppConfigService;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.services.BaseService;
import com.codeinsight.snap_crescent.common.utils.AppConfigKeys;
import com.codeinsight.snap_crescent.common.utils.Constant;
import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.common.utils.FileService;
import com.codeinsight.snap_crescent.config.EnvironmentProperties;
import com.codeinsight.snap_crescent.metadata.Metadata;
import com.codeinsight.snap_crescent.metadata.MetadataRepository;
import com.codeinsight.snap_crescent.metadata.MetadataService;
import com.codeinsight.snap_crescent.sync_info.SyncInfo;
import com.codeinsight.snap_crescent.sync_info.SyncInfoService;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailRepository;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailService;

@Service
public class AssetServiceImpl extends BaseService implements AssetService {

	@Autowired
	private MetadataService metadataService;

	@Autowired
	private ThumbnailService thumbnailService;

	@Autowired
	private AssetRepository assetRepository;

	@Autowired
	private MetadataRepository metadataRepository;

	@Autowired
	private ThumbnailRepository thumbnailRepository;

	@Autowired
	private AppConfigService appConfigService;

	@Autowired
	private FileService fileService;

	@Autowired
	private AssetConverter assetConverter;
	
	@Autowired
	private SyncInfoService syncInfoService; 

	@Transactional
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiAsset> response = new BaseResponseBean<>();

		int count = assetRepository.count(searchCriteria);

		if (count > 0) {

			List<UiAsset> searchResult = assetConverter.getBeansFromEntities(
					assetRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION),
					searchCriteria.getResultType());

			response.setTotalResultsCount(count);
			response.setResultCountPerPage(searchResult.size());
			response.setCurrentPageIndex(searchCriteria.getPageNumber());

			response.setObjects(searchResult);

		}

		return response;
	}

	@Override
	@Transactional
	public void upload(ASSET_TYPE assetType, ArrayList<MultipartFile> multipartFiles) throws Exception {

		String x = appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_SKIP_UPLOADING);
		if (x != null & Boolean.parseBoolean(x) == true) {
			return;
		}
		
		StringBuilder pathBuilder = new StringBuilder(EnvironmentProperties.STORAGE_PATH);
		
		if(assetType == ASSET_TYPE.PHOTO) {
			pathBuilder.append(Constant.PHOTO_FOLDER);
		}
		
		if(assetType == ASSET_TYPE.VIDEO) {
			pathBuilder.append(Constant.VIDEO_FOLDER);
		}
		
		File directory = new File(pathBuilder.toString());
		if (!directory.exists()) {
			directory.mkdir();
		}
		for (MultipartFile multipartFile : multipartFiles) {
			
			String originalFilename = multipartFile.getOriginalFilename();
			String extension =  originalFilename.substring(originalFilename.lastIndexOf("."));
			
			String path = pathBuilder.toString() + UUID.randomUUID().toString() + extension;
			
			multipartFile.transferTo(new File(path));

			File file = new File(path);
			if (isAlreadyExist(file)) {
				continue;
			}
			Asset image = new Asset();
			
			image.setAssetType(assetType);

			Metadata metadata = metadataService.extractMetaData(originalFilename, file);
			Thumbnail thumbnail = thumbnailService.generateThumbnail(file, metadata, assetType);

			metadataRepository.save(metadata);
			thumbnailRepository.save(thumbnail);

			image.setMetadataId(metadata.getId());
			image.setThumbnailId(thumbnail.getId());

			assetRepository.save(image);

		}
		
		SyncInfo syncInfo = new SyncInfo();
		syncInfoService.create(syncInfo);

	}

	private boolean isAlreadyExist(File file) throws Exception {
		boolean exist = false;
		String fileName = file.getName();
		exist = metadataRepository.existsByName(fileName);
		return exist;
	}
	
	@Override
	public UiAsset getById(Long id) {
		return assetConverter.getBeanFromEntity(assetRepository.findById(id), ResultType.FULL) ;
	}


	@Override
	@Transactional
	public byte[] getAssetById(Long id) throws Exception {
		Asset asset = assetRepository.findById(id);
		String fileUniqueName = asset.getMetadata().getPath();
		FILE_TYPE fileType = null;
		
		if(asset.getAssetType() == ASSET_TYPE.PHOTO) {
			fileType = FILE_TYPE.PHOTO;
		}
		
		if(asset.getAssetType() == ASSET_TYPE.VIDEO) {
			fileType = FILE_TYPE.VIDEO;
		}
		
		 
		return fileService.readFileBytes(fileType, fileUniqueName);
	}

	@Override
	@Transactional
	public void update(UiAsset enity) throws Exception {
		// TODO Auto-generated method stub
		
	}

	
}
