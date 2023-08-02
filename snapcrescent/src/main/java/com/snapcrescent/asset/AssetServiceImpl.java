package com.snapcrescent.asset;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.snapcrescent.album.AlbumService;
import com.snapcrescent.appConfig.AppConfigService;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.AppConfigKeys;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.common.utils.StringUtils;
import com.snapcrescent.metadata.Metadata;
import com.snapcrescent.metadata.MetadataRepository;
import com.snapcrescent.metadata.MetadataService;
import com.snapcrescent.thumbnail.Thumbnail;
import com.snapcrescent.thumbnail.ThumbnailRepository;
import com.snapcrescent.thumbnail.ThumbnailService;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
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
	private AlbumService albumService;

	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;

	@Transactional
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiAsset> response = new BaseResponseBean<>();

		int count = assetRepository.count(searchCriteria);

		if (count > 0) {

			List<Asset> entities = assetRepository.search(searchCriteria,
					searchCriteria.getResultType() == ResultType.OPTION);
			List<UiAsset> beans = assetConverter.getBeansFromEntities(entities, searchCriteria.getResultType());

			for (int i = 0; i < beans.size(); i++) {
				UiAsset bean = beans.get(i);
				bean.getThumbnail()
						.setToken(securedStreamTokenUtil.getSignedAssetStreamToken(entities.get(i).getThumbnail()));
			}

			response.setTotalResultsCount(count);
			response.setResultCountPerPage(beans.size());
			response.setCurrentPageIndex(searchCriteria.getPageNumber());

			response.setObjects(beans);

		}

		return response;
	}

	@Override
	public String uploadAssets(List<MultipartFile> multipartFiles) throws Exception {

		String directoryPath = null;

		String isDemoAppString = appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_DEMO_APP);
		if (isDemoAppString == null || Boolean.parseBoolean(isDemoAppString) == false) {
			
			directoryPath = fileService.getBasePath(coreService.getAppUserId()) + "/" + UUID.randomUUID().toString()+ "/";
			fileService.mkdirs(directoryPath);

			for (MultipartFile multipartFile : multipartFiles) {
				try {
					String path = directoryPath + StringUtils.generateTemporaryFileName(multipartFile.getOriginalFilename());
					multipartFile.transferTo(new File(path));
				} catch (Exception e) {
					log.error("Error saving multipar file", e);
				}
			}

		}

		return directoryPath;
	}

	@Override
	@Transactional
	@Async("threadPoolTaskExecutor")
	public Future<Boolean> processAsset( File temporaryFile, Long userId) {

		Boolean completed = false;
		
		try {
			Metadata metadata = metadataService.createMetadataEntity(temporaryFile);
			metadata.setCreatedByUserId(userId);
			
			Thumbnail thumbnail = thumbnailService.createThumbnailEntity(metadata);
			thumbnail.setCreatedByUserId(userId);
			
			Asset asset = null;

			Asset matchingAsset = assetRepository.findByHash(metadata.getHash(), metadata.getCreatedByUserId());

			if (matchingAsset == null) {
				
				AssetType assetType = FileService.getAssetType(temporaryFile.getName());

				String directoryPath = fileService.getBasePath(assetType, userId) + metadata.getPath();
				fileService.mkdirs(directoryPath);

				File finalFile = new File(directoryPath + "/" + metadata.getInternalName());
				Files.move(Paths.get(temporaryFile.getAbsolutePath()), Paths.get(finalFile.getAbsolutePath()));

				asset = new Asset();
				asset.setCreatedByUserId(userId);
				asset.setAssetType(assetType.getId());
				
				metadataRepository.save(metadata);
				thumbnailRepository.save(thumbnail);

				asset.setMetadata(metadata);
				asset.setMetadataId(metadata.getId());
				
				asset.setThumbnail(thumbnail);
				asset.setThumbnailId(thumbnail.getId());
				
				assetRepository.save(asset);
				
				thumbnailService.generateThumbnail(asset);
				
				albumService.persistAlbumAssetAssociationForDefaultAlbum(userId, asset);
				

			}
			
			completed = true;
		} catch (Exception e) {
			log.error("Exception while processing asset", e);
		}

		return CompletableFuture.completedFuture(completed);
	}

	@Override
	@Transactional
	public Boolean processAsset(AssetType assetType, File temporaryFile, Metadata metadata) throws Exception {

		boolean processed = false;
		try {
			// Thumbnail thumbnail = thumbnailService.generateThumbnail(temporaryFile,
			// metadata, assetType);
			// saveProcessedAsset(assetType, temporaryFile, metadata, thumbnail);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			processed = true;
		}

		return processed;
	}

	@Override
	public UiAsset getById(Long id) {

		UiAsset bean = null;

		Asset entity = assetRepository.findById(id);
		bean = assetConverter.getBeanFromEntity(entity, ResultType.FULL);
		bean.setToken(securedStreamTokenUtil.getSignedAssetStreamToken(entity));

		return bean;
	}

	@Override
	@Transactional
	public byte[] getAssetById(Long id) throws Exception {
		Asset asset = assetRepository.findById(id);

		FILE_TYPE fileType = null;

		if (asset.getAssetTypeEnum() == AssetType.PHOTO) {
			fileType = FILE_TYPE.PHOTO;
		}

		if (asset.getAssetTypeEnum() == AssetType.VIDEO) {
			fileType = FILE_TYPE.VIDEO;
		}

		return fileService.readFileBytes(fileType, asset.getCreatedByUserId(), asset.getMetadata().getPath(),
				asset.getMetadata().getInternalName());
	}


	@Override
	public File migrateAssets(AssetType assetType, File originalFile) throws Exception {

		File finalFile = null;

		String directoryPath = fileService.getBasePath(assetType, coreService.getAppUserId())
				+ Constant.UNPROCESSED_ASSET_FOLDER;
		fileService.mkdirs(directoryPath);

		try {
			String path = directoryPath + StringUtils.generateTemporaryFileName(
					originalFile.getName().replace("(", "").replace(")", "").replaceAll("\\s", ""));
			finalFile = new File(path);

			Files.copy(originalFile.toPath(), finalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return finalFile;

	}

	@Override
	@Transactional
	public void updateActiveFlag(Boolean active, List<Long> ids) {
		assetRepository.updateActiveFlag(active, ids);
	}

	@Override
	@Transactional
	public void updateFavoriteFlag(Boolean favorite, List<Long> ids) {
		assetRepository.updateFavoriteFlag(favorite, ids);
	}

	@Override
	@Transactional
	public void deletePermanently(List<Long> ids) {

		List<Asset> assets = assetRepository.findByIds(ids);

		for (Asset asset : assets) {
			try {
				if (asset.getCreatedByUserId() == coreService.getAppUserId() || coreService.getAppUser().isAdmin()) {
					albumService.updateAlbumPostAssetDeletion(asset);
					assetRepository.delete(asset);
				}

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	@Override
	public SecuredAssetStreamDTO getAssetDetailsFromToken(String token) throws Exception {
		return securedStreamTokenUtil.getAssetDetailsFromToken(token);
	}

	@Override
	@Transactional
	public List<UiAssetTimeline> getAssetTimeline(AssetSearchCriteria searchCriteria) {
		return assetRepository.getAssetTimeline(searchCriteria);
	}

	@Override
	@Transactional
	public void deleteAssetPostUserDeletion(Long userId) throws Exception {
		deletePermanently(assetRepository.findAssetIdsByCreatedById(userId));
		fileService.removeFile(userId);
		assetRepository.flush();
	}

	@Override
	@Transactional
	public void update(Asset asset) {
		assetRepository.update(asset);

	}

}
