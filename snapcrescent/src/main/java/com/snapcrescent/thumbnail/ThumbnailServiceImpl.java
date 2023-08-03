package com.snapcrescent.thumbnail;

import java.awt.image.BufferedImage;
import java.io.File;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.SecuredAssetStreamDTO;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.ImageUtils;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.metadata.Metadata;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class ThumbnailServiceImpl extends BaseService implements ThumbnailService {

	@Autowired
	private FileService fileService;

	@Autowired
	private ThumbnailRepository thumbnailRepository;

	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;

	private final String FILE_TYPE_SEPARATOR = ".";

	@Override
	public Thumbnail createThumbnailEntity(Metadata metadata) throws Exception {

		String extension = "jpg";
		String name = metadata.getInternalName() + Constant.THUMBNAIL_OUTPUT_NAME_SUFFIX + FILE_TYPE_SEPARATOR + extension;
		String path = metadata.getPath();

		Thumbnail thumbnail = new Thumbnail();
		thumbnail.setName(name);
		thumbnail.setPath(path);
		return thumbnail;

	}
	
	@Override
	@Transactional
	public Future<Boolean> generateThumbnailAsync(Asset asset) {
		Boolean completed = false;
		completed = generateThumbnail(asset);
		return CompletableFuture.completedFuture(completed);
	}

	@Override
	@Transactional
	public Boolean generateThumbnail(Asset asset) {
		
		Boolean completed = false;

		try {
			AssetType assetType = AssetType.findById(asset.getAssetType());
			FILE_TYPE fileType = FILE_TYPE.findAssetType(assetType);
			Metadata metadata = asset.getMetadata();

			Thumbnail thumbnail = thumbnailRepository.findById(asset.getThumbnailId());

			File assetFile = fileService.getFile(fileType, thumbnail.getCreatedByUserId(),
					asset.getMetadata().getPath(), asset.getMetadata().getInternalName());

			String directoryPath = fileService.getBasePath(FILE_TYPE.THUMBNAIL, thumbnail.getCreatedByUserId()) + thumbnail.getPath();
			fileService.mkdirs(directoryPath);
			
			String outputFilePath = directoryPath + "/" + thumbnail.getName();

			BufferedImage extractedImage = extractImage(assetType, assetFile, metadata, outputFilePath);
			BufferedImage resizedImage = ImageUtils.cropAndResizeThumnail(extractedImage, metadata);

			// Save Image as generated thumbnail
			
			File outputFile = new File(outputFilePath);
			ImageIO.write(resizedImage, "jpg", outputFile);
			
			completed = true;
		} catch (Exception e) {
			log.error("Error while generating thumbnail for asset=" + asset.getId(), e);
		}
		
		return completed;
	}

	@Override
	@Transactional
	public String getFilePathByThumbnailById(Long id) throws Exception {
		Thumbnail thumbnail = thumbnailRepository.findById(id);
		return fileService
				.getFile(FILE_TYPE.THUMBNAIL, thumbnail.getCreatedByUserId(), thumbnail.getPath(), thumbnail.getName())
				.getAbsolutePath();
	}

	@Override
	public SecuredAssetStreamDTO getAssetDetailsFromToken(String token) throws Exception {
		return securedStreamTokenUtil.getAssetDetailsFromToken(token);
	}

	private BufferedImage extractImage(AssetType assetType, File file, Metadata metadata, String outputFilePath) throws Exception {

		BufferedImage original = null;

		if (assetType == AssetType.PHOTO) {
			if (metadata.getFileExtension() != null && !metadata.getFileExtension().equals("webp")) {
				original = ImageIO.read(file);
			}
		}

		if (assetType == AssetType.VIDEO) {
			original = ImageUtils.extractImageFromVideo(file.getAbsolutePath(), outputFilePath);
		}

		return original;
	}

}
