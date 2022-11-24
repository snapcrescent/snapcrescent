package com.codeinsight.snap_crescent.thumbnail;

import java.awt.Image;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.File;

import javax.imageio.ImageIO;

import org.bytedeco.javacv.FFmpegFrameGrabber;
import org.bytedeco.javacv.Frame;
import org.bytedeco.javacv.Java2DFrameConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.common.utils.Constant.FILE_TYPE;
import com.codeinsight.snap_crescent.common.utils.FileService;
import com.codeinsight.snap_crescent.metadata.Metadata;
@Service
public class ThumbnailServiceImpl implements ThumbnailService {

	@Value("${thumbnail.size.width}")
	private int THUMBNAIL_WIDTH;

	@Value("${thumbnail.size.height}")
	private int THUMBNAIL_HEIGHT;

	@Value("${thumbnail.output.nameSuffix}")
	private String THUMBNAIL_OUTPUT_NAME_SUFFIX;

	@Autowired
	private FileService fileService;

	@Autowired
	private ThumbnailRepository thumbnailRepository;

	private final String FILE_TYPE_SEPARATOR = ".";

	public Thumbnail generateThumbnail(File file, Metadata metadata, AssetType assetType) throws Exception {

		File thumbnailFile = createThumbnail(assetType, file, metadata);
		
		Thumbnail thumbnail = new Thumbnail();
		String thumbnailName = thumbnailFile.getName();
		thumbnail.setName(thumbnailName);
		thumbnail.setPath(metadata.getPath());
		return thumbnail;
		
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
				FFmpegFrameGrabber frameGrabber = new FFmpegFrameGrabber(file);
				frameGrabber.start();

				
				Frame frame = frameGrabber.grabImage();
				Java2DFrameConverter java2DFrameConverter = new Java2DFrameConverter();
				original = java2DFrameConverter.convert(frame);
			
				java2DFrameConverter.close();
				frameGrabber.stop();
				frameGrabber.close();
			}
			
		

		return original;
	}

	
	private BufferedImage rotateCropAndResizeThumnail(BufferedImage original, Metadata metadata) {
		// Rotate Image based on EXIF orientation
		AffineTransform transform = getExifTransformation(metadata.getOrientation(), original.getWidth(),
				original.getHeight());
		AffineTransformOp op = new AffineTransformOp(transform, AffineTransformOp.TYPE_BILINEAR);
		original = op.filter(original, null);

		// Crop Image for a square thumbnail
		int side = Math.min(original.getWidth(), original.getHeight());
		int x = (original.getWidth() - side) / 2;
		int y = (original.getHeight() - side) / 2;
		BufferedImage cropped = original.getSubimage(x, y, side, side);

		// Resize Image
		Image scaledImage = cropped.getScaledInstance(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT,
				BufferedImage.SCALE_SMOOTH);
		BufferedImage bufferedImage = new BufferedImage(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT,
				BufferedImage.TYPE_INT_RGB);
		bufferedImage.createGraphics().drawImage(scaledImage, 0, 0, null);
		
		return bufferedImage;
	}

	private String getThumbnailName(Metadata metadata) {
		String extension = "jpg";
		return metadata.getInternalName() + THUMBNAIL_OUTPUT_NAME_SUFFIX + FILE_TYPE_SEPARATOR + extension;
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

}
