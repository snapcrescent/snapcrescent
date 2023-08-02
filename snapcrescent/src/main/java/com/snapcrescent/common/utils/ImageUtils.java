package com.snapcrescent.common.utils;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;

import javax.imageio.ImageIO;

import com.snapcrescent.config.EnvironmentProperties;

public class ImageUtils {

	public static long getPerceptualHash(final Image image) {
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
	
	public static BufferedImage extractImageFromVideo(String videoFilePath, String tempPath) throws Exception {
		
		File tempFile = new File(tempPath);
		
		String ffmpegCommand = "ffmpeg -i " + videoFilePath + " -vf thumbnail=25 -vframes 1 -qscale 0 " + tempPath + "";
		
		ProcessBuilder processBuilder = null;
		
		if(OSFinder.isWindows()) {
			processBuilder = new ProcessBuilder("cmd.exe","/C " + ffmpegCommand);	
		} else if(OSFinder.isUnix()) {
			processBuilder =  new ProcessBuilder("/bin/bash","-c", ffmpegCommand);	
		}
		
		processBuilder.directory(new File(EnvironmentProperties.FFMPEG_PATH));
		executeProcess(processBuilder);
		
		BufferedImage original = ImageIO.read(tempFile);
		tempFile.delete();
		
		return original;
	}

	private static void executeProcess(ProcessBuilder builder) throws Exception {
		builder.redirectErrorStream(true);
		Process p = builder.start();
		BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()));
		String line;
		while (true) {
			line = r.readLine();
			if (line == null) {
				break;
			}
		}
	}

	public static  BufferedImage cropAndResizeThumnail(BufferedImage original) {
		int scaledHeightInteger = Constant.THUMBNAIL_HEIGHT;
		BigDecimal scaledHeight = new BigDecimal(scaledHeightInteger);

		BigDecimal aspectRatio = new BigDecimal(original.getWidth()).divide(new BigDecimal(original.getHeight()), 2,
				RoundingMode.HALF_UP);

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

}
