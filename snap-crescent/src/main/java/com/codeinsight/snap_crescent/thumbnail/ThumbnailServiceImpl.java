package com.codeinsight.snap_crescent.thumbnail;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

@Service
public class ThumbnailServiceImpl implements ThumbnailService{

	@Value("${thumbnail.size.width}")
	private int THUMBNAIL_WIDTH;

	@Value("${thumbnail.size.height}")
	private int THUMBNAIL_HEIGHT;

	@Value("${thumbnail.output.path}")
	private String THUMBNAIL_OUTPUT_PATH;

	@Value("${thumbnail.output.nameSuffix}")
	private String THUMBNAIL_OUTPUT_NAME_SUFFIX;

	@Value("${thumbnail.output.type}")
	private String THUMBNAIL_OUTPUT_TYPE;

	private final String FILE_TYPE_SEPARATOR = ".";

	public Thumbnail generateThumbnail(File file) throws Exception{

		boolean isThumbnailCreated = createThumbnail(file);

		if (isThumbnailCreated) {
			Thumbnail thumbnail = new Thumbnail();
			thumbnail.setName(getThumbnailName(file));
			thumbnail.setPath(THUMBNAIL_OUTPUT_PATH);

			return thumbnail;
		}

		return null;
	}

	private boolean createThumbnail(File file) {
		boolean isThumbnailCreated = false;
		try {
			Image scaledImage = ImageIO.read(file).getScaledInstance(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT,
					BufferedImage.SCALE_SMOOTH);

			BufferedImage bufferedImage = new BufferedImage(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT,
					BufferedImage.TYPE_INT_RGB);
			bufferedImage.createGraphics().drawImage(scaledImage, 0, 0, null);

			File outputFile = new File(THUMBNAIL_OUTPUT_PATH + getThumbnailName(file));
			ImageIO.write(bufferedImage, THUMBNAIL_OUTPUT_TYPE, outputFile);

			isThumbnailCreated = true;
		} catch (IOException exception) {
			System.out.println("Unable to read image file: " + file.getName());
		}

		return isThumbnailCreated;
	}

	private String getThumbnailName(File file) {
		return file.getName().substring(0, file.getName().lastIndexOf(FILE_TYPE_SEPARATOR))
				+ THUMBNAIL_OUTPUT_NAME_SUFFIX + FILE_TYPE_SEPARATOR + THUMBNAIL_OUTPUT_TYPE;
	}

}
