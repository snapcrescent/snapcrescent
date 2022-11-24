package com.codeinsight.snap_crescent.asset;

import static com.codeinsight.snap_crescent.common.utils.Constant.ACCEPT_RANGES;
import static com.codeinsight.snap_crescent.common.utils.Constant.BYTES;
import static com.codeinsight.snap_crescent.common.utils.Constant.CHUNK_SIZE;
import static com.codeinsight.snap_crescent.common.utils.Constant.CONTENT_LENGTH;
import static com.codeinsight.snap_crescent.common.utils.Constant.CONTENT_RANGE;
import static com.codeinsight.snap_crescent.common.utils.Constant.CONTENT_TYPE;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.Future;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
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
import com.codeinsight.snap_crescent.common.utils.FileService;
import com.codeinsight.snap_crescent.common.utils.StringUtils;
import com.codeinsight.snap_crescent.metadata.Metadata;
import com.codeinsight.snap_crescent.metadata.MetadataRepository;
import com.codeinsight.snap_crescent.metadata.MetadataService;
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
	public List<File> uploadAssets(AssetType assetType, List<MultipartFile> multipartFiles) throws Exception {

		List<File> files = new LinkedList<>();
		String x = appConfigService.getValue(AppConfigKeys.APP_CONFIG_KEY_SKIP_UPLOADING);
		if (x != null & Boolean.parseBoolean(x) == true) {
			return files;
		}

		String directoryPath = fileService.getBasePath(assetType) + Constant.UNPROCESSED_ASSET_FOLDER;
		fileService.mkdirs(directoryPath);

		for (MultipartFile multipartFile : multipartFiles) {
			try {

				String path = directoryPath
						+ StringUtils.generateTemporaryFileName(multipartFile.getOriginalFilename());

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
	public Future<Boolean> processAsset(AssetType assetType, File temporaryFile) throws Exception {

		boolean processed = false;
		try {
			String originalFilename = StringUtils.extractFileNameFromTemporary(temporaryFile.getName());

			Metadata metadata = metadataService.extractMetaData(originalFilename, temporaryFile);
			Thumbnail thumbnail = thumbnailService.generateThumbnail(temporaryFile, metadata, assetType);

			long assetHash = getPerceptualHash(
					ImageIO.read(fileService.getFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName())));

			if (metadataRepository.existsByHash(assetHash) == false) {

				String directoryPath = fileService.getBasePath(assetType) + metadata.getPath();
				fileService.mkdirs(directoryPath);

				File finalFile = new File(directoryPath + "/" + metadata.getInternalName());
				Files.move(Paths.get(temporaryFile.getAbsolutePath()), Paths.get(finalFile.getAbsolutePath()));

				Asset asset = new Asset();
				asset.setAssetType(assetType.getId());

				metadata.setHash(assetHash);

				metadataRepository.save(metadata);
				thumbnailRepository.save(thumbnail);

				asset.setMetadataId(metadata.getId());
				asset.setThumbnailId(thumbnail.getId());

				assetRepository.save(asset);
			} else {
				if (assetType == AssetType.PHOTO) {
					fileService.removeFile(FILE_TYPE.PHOTO, Constant.UNPROCESSED_ASSET_FOLDER, temporaryFile.getName());
				} else if (assetType == AssetType.VIDEO) {
					fileService.removeFile(FILE_TYPE.VIDEO, Constant.UNPROCESSED_ASSET_FOLDER, temporaryFile.getName());
				}

				fileService.removeFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName());
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			processed = true;
		}

		return new AsyncResult<Boolean>(processed);
	}

	@Override
	public UiAsset getById(Long id) {
		return assetConverter.getBeanFromEntity(assetRepository.findById(id), ResultType.FULL);
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
	public ResponseEntity<byte[]> streamAssetById(Long id, String range) throws Exception {
		Asset asset = assetRepository.findById(id);
		
		try {
            long rangeStart = 0;
            long rangeEnd = CHUNK_SIZE;
            final Long fileSize = fileService.getFileSize(FILE_TYPE.VIDEO,  asset.getMetadata().getPath(), asset.getMetadata().getInternalName());
            if (range == null) {
                return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                        .header(CONTENT_TYPE, asset.getMetadata().getMimeType())
                        .header(ACCEPT_RANGES, BYTES)
                        .header(CONTENT_LENGTH, String.valueOf(rangeEnd))
                        .header(CONTENT_RANGE, BYTES + " " + rangeStart + "-" + rangeEnd + "/" + fileSize)
                        .header(CONTENT_LENGTH, String.valueOf(fileSize))
                        .body(readByteRange(id, rangeStart, rangeEnd)); // Read the object and convert it as bytes
            }
            String[] ranges = range.split("-");
            rangeStart = Long.parseLong(ranges[0].substring(6));
            if (ranges.length > 1) {
                rangeEnd = Long.parseLong(ranges[1]);
            } else {
                rangeEnd = rangeStart + CHUNK_SIZE;
            }

            rangeEnd = Math.min(rangeEnd, fileSize - 1);
            final byte[] data = readByteRange(id, rangeStart, rangeEnd);
            final String contentLength = String.valueOf((rangeEnd - rangeStart) + 1);
            HttpStatus httpStatus = HttpStatus.PARTIAL_CONTENT;
            if (rangeEnd >= fileSize) {
                httpStatus = HttpStatus.OK;
            }
            return ResponseEntity.status(httpStatus)
                    .header(CONTENT_TYPE, asset.getMetadata().getMimeType())
                    .header(ACCEPT_RANGES, BYTES)
                    .header(CONTENT_LENGTH, contentLength)
                    .header(CONTENT_RANGE, BYTES + " " + rangeStart + "-" + rangeEnd + "/" + fileSize)
                    .body(data);
        } catch (IOException e) {
            logger.error("Exception while reading the file {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
	}
	
	public byte[] readByteRange(Long id, long start, long end) throws Exception {
        byte[] data = getAssetById(id);
        byte[] result = new byte[(int) (end - start) + 1];
        System.arraycopy(data, (int) start, result, 0, (int) (end - start) + 1);
        return result;
    }


	@Override
	@Transactional
	public void update(UiAsset enity) throws Exception {
		// TODO Auto-generated method stub

	}

	@Override
	public File migrateAssets(AssetType assetType, File originalFile) throws Exception {

		File finalFile = null;

		String directoryPath = fileService.getBasePath(assetType) + Constant.UNPROCESSED_ASSET_FOLDER;
		fileService.mkdirs(directoryPath);

		try {
			String path = directoryPath + StringUtils.generateTemporaryFileName(originalFile.getName());
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

				//metadataRepository.delete(metadata);
				//thumbnailRepository.delete(thumbnail);
				assetRepository.delete(asset);
			} catch (Exception e) {
				e.printStackTrace();
			}

		}

	}



}
