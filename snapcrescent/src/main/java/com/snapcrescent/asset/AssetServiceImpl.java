package com.snapcrescent.asset;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.snapcrescent.album.Album;
import com.snapcrescent.album.AlbumRepository;
import com.snapcrescent.appConfig.AppConfigService;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.AppConfigKeys;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.DateUtils;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.common.utils.StringUtils;
import com.snapcrescent.metadata.Metadata;
import com.snapcrescent.metadata.MetadataRepository;
import com.snapcrescent.metadata.MetadataService;
import com.snapcrescent.thumbnail.Thumbnail;
import com.snapcrescent.thumbnail.ThumbnailRepository;
import com.snapcrescent.thumbnail.ThumbnailService;

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
	private AlbumRepository albumRepository;
	
	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;

	@Transactional
	public BaseResponseBean<Long, UiAsset> search(AssetSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiAsset> response = new BaseResponseBean<>();

		int count = assetRepository.count(searchCriteria);

		if (count > 0) {
			
			List<Asset> entities = assetRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION);
			List<UiAsset> beans = assetConverter.getBeansFromEntities(entities, searchCriteria.getResultType());
			
			for (int i = 0; i < beans.size(); i++) {
				UiAsset bean = beans.get(i);
				bean.getThumbnail().setToken(securedStreamTokenUtil.getSignedAssetStreamToken(entities.get(i).getThumbnail()));
			}
			
			response.setTotalResultsCount(count);
			response.setResultCountPerPage(beans.size());
			response.setCurrentPageIndex(searchCriteria.getPageNumber());

			response.setObjects(beans);
		
		}

		return response;
	}

	@Override
	public List<File> uploadAssets(List<MultipartFile> multipartFiles) throws Exception {

		List<File> files = new LinkedList<>();
		String x = appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_DEMO_APP);
		if (x != null & Boolean.parseBoolean(x) == true) {
			return files;
		}

		for (MultipartFile multipartFile : multipartFiles) {
			try {
				
				AssetType assetType = FileService.getAssetType(multipartFile.getOriginalFilename());
				
				String directoryPath = fileService.getBasePath(assetType, coreService.getAppUserId()) + Constant.UNPROCESSED_ASSET_FOLDER;
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
	public Future<Boolean> processAssets(List<File> temporaryFiles) throws Exception {
		boolean processed = false;
		
		for (File temporaryFile : temporaryFiles) {
			processAsset(temporaryFile);
		}
		
		return CompletableFuture.completedFuture(processed);
	}
	
	@Override
	@Transactional
	@Async("threadPoolTaskExecutor")
	public CompletableFuture<Boolean> processAsset(File temporaryFile) throws Exception {

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

		return CompletableFuture.completedFuture(processed);
	}
	
	@Override
	@Transactional
	@Async("threadPoolTaskExecutor")
	public CompletableFuture<Boolean> processAsset(AssetType assetType, File temporaryFile, Metadata metadata) throws Exception {

		boolean processed = false;
		try {
			Thumbnail thumbnail = thumbnailService.generateThumbnail(temporaryFile, metadata, assetType);
			saveProcessedAsset(assetType, temporaryFile, metadata, thumbnail);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			processed = true;
		}

		return CompletableFuture.completedFuture(processed);
	}
	
	public void saveProcessedAsset(AssetType assetType,File temporaryFile, Metadata metadata, Thumbnail thumbnail) throws IOException {
		
		long assetHash = getPerceptualHash(ImageIO.read(fileService.getFile(FILE_TYPE.THUMBNAIL, coreService.getAppUserId(), thumbnail.getPath(), thumbnail.getName())));
		metadata.setHash(assetHash);
		
		Metadata existingMetadata =  metadataRepository.findByHash(metadata.getHash(), metadata.getCreatedByUserId());
		
		if (existingMetadata == null) {

			String directoryPath = fileService.getBasePath(assetType, coreService.getAppUserId()) + metadata.getPath();
			fileService.mkdirs(directoryPath);

			File finalFile = new File(directoryPath + "/" + metadata.getInternalName());
			Files.move(Paths.get(temporaryFile.getAbsolutePath()), Paths.get(finalFile.getAbsolutePath()));

			Asset asset = new Asset();
			asset.setCreatedByUserId(coreService.getAppUserId());
			asset.setAssetType(assetType.getId());

			metadataRepository.save(metadata);
			thumbnailRepository.save(thumbnail);

			asset.setMetadataId(metadata.getId());
			asset.setThumbnailId(thumbnail.getId());

			assetRepository.save(asset);
			
			Album defaultAlbum =  albumRepository.findDefaultAlbumByUserId(coreService.getAppUser().getId());
			
			if(defaultAlbum != null) {
				List<Asset> albumAssets = defaultAlbum.getAssets();
				
				if(albumAssets == null) {
					albumAssets = new ArrayList<Asset>();
				}
				
				albumAssets.add(asset);
				
				defaultAlbum.setAssets(albumAssets);
				
				albumRepository.update(defaultAlbum);
			}
		} else if(metadata != null) {
			
			metadataRepository.detach(existingMetadata);
			
			metadata.setId(existingMetadata.getId());
			metadata.setVersion(existingMetadata.getVersion());
			metadata.setActive(existingMetadata.getActive());
			
			
			moveAssetAndThumbnailPostRecomputeMetaData(assetRepository.findByMetadataId(existingMetadata.getId()), existingMetadata, metadata);
			
			if (assetType == AssetType.PHOTO) {
				fileService.removeFile(FILE_TYPE.PHOTO, coreService.getAppUserId(), Constant.UNPROCESSED_ASSET_FOLDER, temporaryFile.getName());
			} else if (assetType == AssetType.VIDEO) {
				fileService.removeFile(FILE_TYPE.VIDEO, coreService.getAppUserId(), Constant.UNPROCESSED_ASSET_FOLDER, temporaryFile.getName());
			}

			fileService.removeFile(FILE_TYPE.THUMBNAIL, coreService.getAppUserId(), thumbnail.getPath(), thumbnail.getName());
		}
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
		
		return fileService.readFileBytes(fileType,asset.getCreatedByUserId(), asset.getMetadata().getPath(),
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
			File beforeRecomputeAssetFile = fileService.getFile(fileType, asset.getCreatedByUserId(), preRecomputeMetadata.getPath(), preRecomputeMetadata.getInternalName());
			metadataService.recomputeMetaData(assetType, postRecomputeMetadata,beforeRecomputeAssetFile);
			
			moveAssetAndThumbnailPostRecomputeMetaData(asset, preRecomputeMetadata, postRecomputeMetadata);
			
		}catch (Exception e) {
			e.printStackTrace();
		}

	}
	
	private void moveAssetAndThumbnailPostRecomputeMetaData(Asset asset, Metadata preRecomputeMetadata, Metadata postRecomputeMetadata) {
		
			AssetType assetType = AssetType.findById(asset.getAssetType());
			
			FILE_TYPE fileType = null;
	
			if (assetType == AssetType.PHOTO) {
				fileType = FILE_TYPE.PHOTO;
			}
	
			if (assetType == AssetType.VIDEO) {
				fileType = FILE_TYPE.VIDEO;
			}
		
		try {
			File beforeRecomputeAssetFile = fileService.getFile(fileType,asset.getCreatedByUserId(), preRecomputeMetadata.getPath(), preRecomputeMetadata.getInternalName());
			
			String postRecomputePath = DateUtils.getFilePathFromDate(postRecomputeMetadata.getCreationDateTime());
			
			String assetDirectoryPath = fileService.getBasePath(assetType,asset.getCreatedByUserId()) + postRecomputePath;
			fileService.mkdirs(assetDirectoryPath);
			
			
			File finalAssetFile = new File(assetDirectoryPath + "/" + postRecomputeMetadata.getInternalName());
			if(!beforeRecomputeAssetFile.getAbsolutePath().equals(finalAssetFile.getAbsolutePath())) {
				Files.move(Paths.get(beforeRecomputeAssetFile.getAbsolutePath()), Paths.get(finalAssetFile.getAbsolutePath()));	
			}
			
			Thumbnail thumbnail = thumbnailRepository.findById(asset.getThumbnailId());
			
			String thumbnailDirectoryPath = fileService.getBasePath(FILE_TYPE.THUMBNAIL,thumbnail.getCreatedByUserId()) + postRecomputePath;
			fileService.mkdirs(thumbnailDirectoryPath);
			
			File thumbnailFile = fileService.getFile(FILE_TYPE.THUMBNAIL,thumbnail.getCreatedByUserId(), thumbnail.getPath(),thumbnail.getName());
			
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

		String directoryPath = fileService.getBasePath(assetType, coreService.getAppUserId()) + Constant.UNPROCESSED_ASSET_FOLDER;
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
				 if(asset.getCreatedByUserId() == coreService.getAppUserId()
					|| coreService.getAppUser().isAdmin()
						 ) {
					
						List<Album> albums = albumRepository.getAlbumsByThumbnailId(asset.getThumbnailId());
						
						if(albums != null) {
							for (Album album : albums) {
								album.setAlbumThumbnail(null);
								album.setAlbumThumbnailId(null);
								albumRepository.update(album);
							}
						}
						
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
	public void regenerateThumbnails(String assetIdRange, String assetIdList) {
		
		long startingId = Long.parseLong(assetIdRange.split("-")[0]);
		long  endingId = Long.parseLong(assetIdRange.split("-")[1]);
		
		String[] assetIds = assetIdList.split(",");
		
		for (long assetId = startingId; assetId <= endingId; assetId++) {
			regenerateThumbnail(assetId);
		}
		
		for (String assetId : assetIds) {
			regenerateThumbnail(Long.parseLong(assetId));
		}
		
		
	}
	
	private void regenerateThumbnail(long assetId) {
		try {
			Asset asset = assetRepository.findById(assetId);
			
			if(asset != null) {
				FILE_TYPE fileType = null;
				
				if (asset.getAssetType() == AssetType.PHOTO.getId()) {
					fileType = FILE_TYPE.PHOTO;
				}

				if (asset.getAssetType() == AssetType.VIDEO.getId()) {
					fileType = FILE_TYPE.VIDEO;
				}
				
				//File file = fileService.getFile(fileType, asset.getMetadata().getPath(), asset.getMetadata().getInternalName());
				
				
				//metadataService.recomputeMetaData(asset.getAssetTypeEnum(), asset.getMetadata(), file);
				//metadataRepository.update(asset.getMetadata());
				//metadataRepository.flush();
				
				thumbnailService.regenerateThumbnails(asset);	
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
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



	
}
