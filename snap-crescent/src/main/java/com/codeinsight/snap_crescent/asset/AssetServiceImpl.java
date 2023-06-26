package com.codeinsight.snap_crescent.asset;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.Future;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.appConfig.AppConfigService;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.services.BaseService;
import com.codeinsight.snap_crescent.common.utils.AppConfigKeys;
import com.codeinsight.snap_crescent.common.utils.Constant;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.Constant.ResultType;
import com.codeinsight.snap_crescent.common.utils.DateUtils;
import com.codeinsight.snap_crescent.common.utils.FileService;
import com.codeinsight.snap_crescent.common.utils.JsonUtils;
import com.codeinsight.snap_crescent.common.utils.StringEncrypter;
import com.codeinsight.snap_crescent.common.utils.StringUtils;
import com.codeinsight.snap_crescent.metadata.Metadata;
import com.codeinsight.snap_crescent.metadata.MetadataRepository;
import com.codeinsight.snap_crescent.metadata.MetadataService;
import com.codeinsight.snap_crescent.thumbnail.Thumbnail;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailRepository;
import com.codeinsight.snap_crescent.thumbnail.ThumbnailService;
import com.fasterxml.jackson.core.type.TypeReference;

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
	public List<File> uploadAssets(List<MultipartFile> multipartFiles) throws Exception {

		List<File> files = new LinkedList<>();
		String x = appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_SKIP_UPLOADING);
		if (x != null & Boolean.parseBoolean(x) == true) {
			return files;
		}

		for (MultipartFile multipartFile : multipartFiles) {
			try {
				
				AssetType assetType = FileService.getAssetType(multipartFile.getOriginalFilename());
				
				String directoryPath = fileService.getBasePath(assetType) + Constant.UNPROCESSED_ASSET_FOLDER;
				fileService.mkdirs(directoryPath);

				String path = directoryPath + StringUtils.generateTemporaryFileName(multipartFile.getOriginalFilename());

				multipartFile.transferTo(new File(path));

				File file = new File(path);

				files.add(file);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		return files;

	}

	@Override
	@Transactional
	@Async("threadPoolTaskExecutor")
	public Future<Boolean> processAsset(File temporaryFile) throws Exception {

		boolean processed = false;
		try {
			AssetType assetType = FileService.getAssetType(temporaryFile.getName());
			String originalFilename = StringUtils.extractFileNameFromTemporary(temporaryFile.getName());
			Metadata metadata = metadataService.computeMetaData(assetType, originalFilename, temporaryFile);
			Thumbnail thumbnail = thumbnailService.generateThumbnail(temporaryFile, metadata, assetType);
			saveProcessedAsset(assetType, temporaryFile, metadata, thumbnail);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			processed = true;
		}

		return new AsyncResult<Boolean>(processed);
	}
	
	@Override
	@Transactional
	@Async("threadPoolTaskExecutor")
	public Future<Boolean> processAsset(AssetType assetType, File temporaryFile, Metadata metadata) throws Exception {

		boolean processed = false;
		try {
			Thumbnail thumbnail = thumbnailService.generateThumbnail(temporaryFile, metadata, assetType);
			saveProcessedAsset(assetType, temporaryFile, metadata, thumbnail);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			processed = true;
		}

		return new AsyncResult<Boolean>(processed);
	}
	
	public void saveProcessedAsset(AssetType assetType,File temporaryFile, Metadata metadata, Thumbnail thumbnail) throws IOException {
		
		long assetHash = getPerceptualHash(ImageIO.read(fileService.getFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName())));
		metadata.setHash(assetHash);
		
		Metadata existingMetadata =  metadataRepository.findByHash(metadata.getHash());
		
		
		if (existingMetadata == null) {

			String directoryPath = fileService.getBasePath(assetType) + metadata.getPath();
			fileService.mkdirs(directoryPath);

			File finalFile = new File(directoryPath + "/" + metadata.getInternalName());
			Files.move(Paths.get(temporaryFile.getAbsolutePath()), Paths.get(finalFile.getAbsolutePath()));

			Asset asset = new Asset();
			asset.setAssetType(assetType.getId());

			metadataRepository.save(metadata);
			thumbnailRepository.save(thumbnail);

			asset.setMetadataId(metadata.getId());
			asset.setThumbnailId(thumbnail.getId());

			assetRepository.save(asset);
		} else {
			
			metadataRepository.detach(existingMetadata);
			
			metadata.setId(existingMetadata.getId());
			metadata.setVersion(existingMetadata.getVersion());
			metadata.setActive(existingMetadata.getActive());
			
			
			moveAssetAndThumbnailPostRecomputeMetaData(assetRepository.findByMetadataId(existingMetadata.getId()), existingMetadata, metadata);
			
			if (assetType == AssetType.PHOTO) {
				fileService.removeFile(FILE_TYPE.PHOTO, Constant.UNPROCESSED_ASSET_FOLDER, temporaryFile.getName());
			} else if (assetType == AssetType.VIDEO) {
				fileService.removeFile(FILE_TYPE.VIDEO, Constant.UNPROCESSED_ASSET_FOLDER, temporaryFile.getName());
			}

			fileService.removeFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName());
		}
	}
	

	@Override
	public UiAsset getById(Long id) {
		
		UiAsset bean = null;
		
		try {
			Asset entity = assetRepository.findById(id);
			bean = assetConverter.getBeanFromEntity(entity, ResultType.FULL);
			bean.setToken(getSignedAssetStreamToken(entity));	
		} catch (Exception e) {
			e.printStackTrace();
		}
		
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
		
		return fileService.readFileBytes(fileType, asset.getMetadata().getPath(),
				asset.getMetadata().getInternalName());
	}
	
	@Override
	@Transactional
	public void updateMetadata(Long id) throws Exception {
		Asset asset = assetRepository.findById(id); 
		AssetType assetType = asset.getAssetTypeEnum();
		
		FILE_TYPE fileType = null;

		if (assetType == AssetType.PHOTO) {
			fileType = FILE_TYPE.PHOTO;
		}

		if (assetType == AssetType.VIDEO) {
			fileType = FILE_TYPE.VIDEO;
		}
		
		
		try {
			Metadata preRecomputeMetadata = metadataRepository.findById(asset.getMetadataId());
			
			metadataRepository.detach(preRecomputeMetadata);
			
			Metadata postRecomputeMetadata = metadataRepository.findById(asset.getMetadataId());
			File beforeRecomputeAssetFile = fileService.getFile(fileType, preRecomputeMetadata.getPath(), preRecomputeMetadata.getInternalName());
			metadataService.recomputeMetaData(assetType, postRecomputeMetadata,beforeRecomputeAssetFile);
			
			moveAssetAndThumbnailPostRecomputeMetaData(asset, preRecomputeMetadata, postRecomputeMetadata);
			
		}catch (Exception e) {
			e.printStackTrace();
		}

	}
	
	private void moveAssetAndThumbnailPostRecomputeMetaData(Asset asset, Metadata preRecomputeMetadata, Metadata postRecomputeMetadata) {
		
			AssetType assetType = asset.getAssetTypeEnum();
			
			FILE_TYPE fileType = null;
	
			if (assetType == AssetType.PHOTO) {
				fileType = FILE_TYPE.PHOTO;
			}
	
			if (assetType == AssetType.VIDEO) {
				fileType = FILE_TYPE.VIDEO;
			}
		
		try {
			File beforeRecomputeAssetFile = fileService.getFile(fileType, preRecomputeMetadata.getPath(), preRecomputeMetadata.getInternalName());
			
			String postRecomputePath = DateUtils.getFilePathFromDate(postRecomputeMetadata.getCreationDateTime());
			
			String assetDirectoryPath = fileService.getBasePath(assetType) + postRecomputePath;
			fileService.mkdirs(assetDirectoryPath);
			
			
			File finalAssetFile = new File(assetDirectoryPath + "/" + postRecomputeMetadata.getInternalName());
			if(!beforeRecomputeAssetFile.getAbsolutePath().equals(finalAssetFile.getAbsolutePath())) {
				Files.move(Paths.get(beforeRecomputeAssetFile.getAbsolutePath()), Paths.get(finalAssetFile.getAbsolutePath()));	
			}
			
			Thumbnail thumbnail = thumbnailRepository.findById(asset.getThumbnailId());
			
			String thumbnailDirectoryPath = fileService.getBasePath(FILE_TYPE.THUMBNAIL) + postRecomputePath;
			fileService.mkdirs(thumbnailDirectoryPath);
			
			File thumbnailFile = fileService.getFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(),thumbnail.getName());
			
			File finalThumbnailFile = new File(thumbnailDirectoryPath + "/" + thumbnail.getName());
			
			if(!thumbnailFile.getAbsolutePath().equals(finalThumbnailFile.getAbsolutePath())) {
				Files.move(Paths.get(thumbnailFile.getAbsolutePath()), Paths.get(finalThumbnailFile.getAbsolutePath()));	
			}
			
			postRecomputeMetadata.setPath(postRecomputePath);
			thumbnail.setPath(postRecomputePath);
			
			metadataRepository.update(postRecomputeMetadata);
			thumbnailRepository.update(thumbnail);
		}catch (Exception e) {
			e.printStackTrace();
		}

	}

	@Override
	public File migrateAssets(AssetType assetType, File originalFile) throws Exception {

		File finalFile = null;

		String directoryPath = fileService.getBasePath(assetType) + Constant.UNPROCESSED_ASSET_FOLDER;
		fileService.mkdirs(directoryPath);

		try {
			String path = directoryPath + StringUtils.generateTemporaryFileName(originalFile.getName().replace("(", "").replace(")", "").replaceAll("\\s", ""));
			finalFile = new File(path);

			Files.copy(originalFile.toPath(), finalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return finalFile;

	}

	public long getPerceptualHash(final Image image) {
		final BufferedImage scaledImage = new BufferedImage(8, 8, BufferedImage.TYPE_BYTE_GRAY);
		{
			final Graphics2D graphics = scaledImage.createGraphics();
			graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);

			graphics.drawImage(image, 0, 0, 8, 8, null);

			graphics.dispose();
		}

		final int[] pixels = new int[64];
		scaledImage.getData().getPixels(0, 0, 8, 8, pixels);

		final int average;
		{
			int total = 0;

			for (int pixel : pixels) {
				total += pixel;
			}

			average = total / 64;
		}

		long hash = 0;

		for (final int pixel : pixels) {
			hash <<= 1;

			if (pixel > average) {
				hash |= 1;
			}
		}

		return hash;
	}

	@Override
	@Transactional
	public void markActive(List<Long> ids) {
		assetRepository.markActive(ids);

	}

	@Override
	@Transactional
	public void markInactive(List<Long> ids) {
		assetRepository.markInactive(ids);

	}

	@Override
	@Transactional
	public void deletePermanently(List<Long> ids) {

		List<Asset> assets = assetRepository.findByIds(ids);

		for (Asset asset : assets) {
			try {
				Metadata metadata = asset.getMetadata();

				Thumbnail thumbnail = asset.getThumbnail();

				try {
					fileService.removeFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName());
				} catch (Exception e) {
					e.printStackTrace();
				}

				try {
					if (asset.getAssetTypeEnum() == AssetType.PHOTO) {
						fileService.removeFile(FILE_TYPE.PHOTO, metadata.getPath(), metadata.getInternalName());
					} else if (asset.getAssetTypeEnum() == AssetType.VIDEO) {
						fileService.removeFile(FILE_TYPE.VIDEO, metadata.getPath(), metadata.getInternalName());
					}
				} catch (Exception e) {
					e.printStackTrace();
				}

				// metadataRepository.delete(metadata);
				// thumbnailRepository.delete(thumbnail);
				assetRepository.delete(asset);
			} catch (Exception e) {
				e.printStackTrace();
			}

		}

	}

	private String getSignedAssetStreamToken(Asset asset) throws Exception {
		
		FILE_TYPE fileType = null;
		
		//Default 10 seconds
		int tokenAge = 0;
		
		if (asset.getAssetType() == AssetType.PHOTO.getId()) {
			fileType = FILE_TYPE.PHOTO;
		}

		if (asset.getAssetType() == AssetType.VIDEO.getId()) {
			
			tokenAge = ((int)asset.getMetadata().getDuration()) * 2;
			fileType = FILE_TYPE.VIDEO;
		}
		
		if(tokenAge < 10) {
			tokenAge = 30 * 60; // 30 Minutes
		}
		
		String filePath = fileService.getFile(fileType, asset.getMetadata().getPath(), asset.getMetadata().getInternalName()).getAbsolutePath();
		
		SecuredAssetStreamDTO payload = new SecuredAssetStreamDTO();
		
		Calendar validTill = Calendar.getInstance();
		validTill.add(Calendar.SECOND, tokenAge);
		
		payload.setFilePath(filePath);
		payload.setAssetType(asset.getAssetType());
		payload.setValidTill(validTill.getTimeInMillis());
		
		String payloadJson = JsonUtils.writeJsonString(payload);
		String encryptedPayload = StringEncrypter.encrypt(payloadJson);
		
		return encryptedPayload;
	}
	
	@Override
	@Transactional
	public SecuredAssetStreamDTO getAssetDetailsFromToken(String encryptedPayload) throws Exception {
		
		String payloadJson = StringEncrypter.decrypt(encryptedPayload);
		SecuredAssetStreamDTO payload = JsonUtils.getObjectFromJson(payloadJson, new TypeReference<SecuredAssetStreamDTO>() {});
		
		Calendar currentTime = Calendar.getInstance();
		
		if(payload.getValidTill() > currentTime.getTimeInMillis()) {
			return payload;
		} else {
			throw new AuthenticationServiceException("Invalid URL");
		}
	}
}
