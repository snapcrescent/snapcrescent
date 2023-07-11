package com.snapcrescent.thumbnail;

import java.awt.Image;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.SecuredAssetStreamDTO;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.OSFinder;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.config.EnvironmentProperties;
import com.snapcrescent.metadata.Metadata;
@Service
public class ThumbnailServiceImpl extends BaseService implements ThumbnailService {

	@Autowired
	private FileService fileService;
	
	@Autowired
	private ThumbnailRepository thumbnailRepository;
	
	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;

	private final String FILE_TYPE_SEPARATOR = ".";

	public Thumbnail generateThumbnail(File file, Metadata metadata, AssetType assetType) throws Exception {

		File thumbnailFile = createThumbnail(assetType, file, metadata);
		
		Thumbnail thumbnail = new Thumbnail();
		thumbnail.setCreatedByUserId(coreService.getAppUserId());
		String thumbnailName = thumbnailFile.getName();
		thumbnail.setName(thumbnailName);
		thumbnail.setPath(metadata.getPath());
		return thumbnail;
		
	}
	
	
	@Override
	@Transactional
	@Async("threadPoolTaskExecutor")
	public void regenerateThumbnails(Asset asset) {
		
		try {
			FILE_TYPE fileType = null;
			
			if (asset.getAssetType() == AssetType.PHOTO.getId()) {
				fileType = FILE_TYPE.PHOTO;
			}

			if (asset.getAssetType() == AssetType.VIDEO.getId()) {
				fileType = FILE_TYPE.VIDEO;
			}
			
			File file = fileService .getFile(fileType, asset.getMetadata().getPath(), asset.getMetadata().getInternalName());
			
			createThumbnail(asset.getAssetTypeEnum(), file, asset.getMetadata());
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		
	}


	private File createThumbnail(AssetType assetType , File file, Metadata metadata) throws Exception {
		
			String directoryPath = fileService.getBasePath(FILE_TYPE.THUMBNAIL) + metadata.getPath();
			fileService.mkdirs(directoryPath);
			
			BufferedImage extractedImage = extractImage(assetType, file, metadata);
			BufferedImage resizedImage = rotateCropAndResizeThumnail(extractedImage, metadata);

			// Save Image as generated thumbnail
			File outputFile = new File(directoryPath + "/" + getThumbnailName(metadata));
			ImageIO.write(resizedImage,"jpg", outputFile);
	
			return outputFile;
	}
	
	private BufferedImage extractImage(AssetType assetType , File file, Metadata metadata) throws Exception {

			BufferedImage original = null;

			if(assetType == AssetType.PHOTO) {
				if(metadata.getFileExtension() != null && metadata.getFileExtension().equals("webp")) {
					
					/*
					ImageReader reader = ImageIO.getImageReadersByMIMEType("image/webp").next();

			        // Configure decoding parameters
			        WebPReadParam readParam = new WebPReadParam();
			        readParam.setBypassFiltering(true);

			        // Configure the input on the ImageReader
			        reader.setInput(new FileImageInputStream(file));

			        // Decode the image
			        original = reader.read(0, readParam);
			        */
				} else {
					original = ImageIO.read(file);	
				}
			}
			
			if(assetType == AssetType.VIDEO) {
				File videoThumbnailTempFile =  new File(fileService.getBasePath(assetType) + Constant.UNPROCESSED_ASSET_FOLDER + file.getName() + "_thumbnail.jpg");
				
				String ffmpegCommand = "ffmpeg -i " + file.getAbsolutePath() + " -vf thumbnail=25 -vframes 1 -qscale 0 " + videoThumbnailTempFile.getAbsolutePath() + "";
				
				ProcessBuilder processBuilder = null;
				
				if(OSFinder.isWindows()) {
					processBuilder = new ProcessBuilder("cmd.exe","/C " + ffmpegCommand);	
				} else if(OSFinder.isUnix()) {
					processBuilder =  new ProcessBuilder("/bin/bash","-c", ffmpegCommand);	
				}
				
				processBuilder.directory(new File(EnvironmentProperties.FFMPEG_PATH));
				executeProcess(processBuilder);
				
				original = ImageIO.read(videoThumbnailTempFile);
				videoThumbnailTempFile.delete();
			}
			
		

		return original;
	}
	
	private void executeProcess(ProcessBuilder builder) throws Exception
	{
		builder.redirectErrorStream(true);
        Process p = builder.start();
        BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String line;
        while (true) {
            line = r.readLine();
            if (line == null) { break; }
            System.out.println(line);
        }
	}

	
	private BufferedImage rotateCropAndResizeThumnail(BufferedImage original, Metadata metadata) {
		// Rotate Image based on EXIF orientation
		AffineTransform transform = getExifTransformation(metadata.getOrientation(), original.getWidth(),
				original.getHeight());
		AffineTransformOp op = new AffineTransformOp(transform, AffineTransformOp.TYPE_BILINEAR);
		original = op.filter(original, null);

		// Crop Image for a square thumbnail
		/*
		int side = Math.min(original.getWidth(), original.getHeight());
		int x = (original.getWidth() - side) / 2;
		int y = (original.getHeight() - side) / 2;
		BufferedImage cropped = original.getSubimage(x, y, side, side);
		*/
		
		int scaledHeightInteger = Constant.THUMBNAIL_HEIGHT;
		BigDecimal scaledHeight = new BigDecimal(scaledHeightInteger);
		
		BigDecimal aspectRatio = new BigDecimal(original.getWidth()).divide(new BigDecimal(original.getHeight()), 2, RoundingMode.HALF_UP);
		
		BigDecimal scaledWidth = scaledHeight.multiply(aspectRatio);
		
		int scaledWidthInteger = scaledWidth.setScale(0, RoundingMode.HALF_UP).intValue();
		
		
		// Resize Image
		Image scaledImage = original.getScaledInstance(scaledWidthInteger, scaledHeightInteger,
				BufferedImage.SCALE_SMOOTH);
		BufferedImage bufferedImage = new BufferedImage(scaledWidthInteger, scaledHeightInteger,
				BufferedImage.TYPE_INT_RGB);
		bufferedImage.createGraphics().drawImage(scaledImage, 0, 0, null);
		
		return bufferedImage;
	}

	private String getThumbnailName(Metadata metadata) {
		String extension = "jpg";
		return metadata.getInternalName() + Constant.THUMBNAIL_OUTPUT_NAME_SUFFIX + FILE_TYPE_SEPARATOR + extension;
	}
	
	@Override
	@Transactional
	public String getFilePathByThumbnailById(Long id) throws Exception {
		Thumbnail thumbnail = thumbnailRepository.findById(id);
		return fileService.getFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName()).getAbsolutePath();
	}

	@Override
	@Transactional
	public byte[] getById(Long id) {
		Thumbnail thumbnail = thumbnailRepository.findById(id);
		return fileService.readFileBytes(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName());
	}

	public static AffineTransform getExifTransformation(int orientation, int width, int height) {

		AffineTransform t = new AffineTransform();

		switch (orientation) {
		case 1:
			break;
		case 2: // Flip X
			t.scale(-1.0, 1.0);
			t.translate(-width, 0);
			break;
		case 3: // PI rotation
			t.translate(width, height);
			t.rotate(Math.PI);
			break;
		case 4: // Flip Y
			t.scale(1.0, -1.0);
			t.translate(0, -height);
			break;
		case 5: // - PI/2 and Flip X
			t.rotate(-Math.PI / 2);
			t.scale(-1.0, 1.0);
			break;
		case 6: // -PI/2 and -width
			t.translate(height, 0);
			t.rotate(Math.PI / 2);
			break;
		case 7: // PI/2 and Flip
			t.scale(-1.0, 1.0);
			t.translate(-height, 0);
			t.translate(0, width);
			t.rotate(3 * Math.PI / 2);
			break;
		case 8: // PI / 2
			t.translate(0, width);
			t.rotate(3 * Math.PI / 2);
			break;
		}

		return t;
	}

	@Override
	public SecuredAssetStreamDTO getAssetDetailsFromToken(String token) throws Exception {
		return securedStreamTokenUtil.getAssetDetailsFromToken(token);
	}

	

}
