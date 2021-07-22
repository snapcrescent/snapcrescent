package com.codeinsight.snap_crescent.common.utils;

import java.util.UUID;

public class StringUtils extends org.apache.commons.lang3.StringUtils {

	public static String getBeautifiedCouponCode(String couponCode) {
		StringBuffer stringBuffer = new StringBuffer();
		String[] tokens = couponCode.split("(?<=\\G.{" + 4 + "})");

		boolean isFirstToken = true;
		for (String token : tokens) {
			if (isFirstToken == false) {
				stringBuffer.append("-");
			}
			stringBuffer.append(token);
			isFirstToken = false;
		}

		return stringBuffer.toString();
	}

	public static String replaceString(String string, String replace, String replaceWith) {
		return string.replace(replace, replaceWith);
	}
	
	public static String generateTemporaryFileName(String uploadedFilename) {
		
		String originalFilename = uploadedFilename.substring(0, uploadedFilename.lastIndexOf("."));
		String extension = uploadedFilename.substring(uploadedFilename.lastIndexOf("."));
		
		return UUID.randomUUID().toString() + Constant.UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR +  originalFilename + extension;
	}
	
	public static String generateFinalFileName(String temporaryFileName) {
		String extension = temporaryFileName.substring(temporaryFileName.lastIndexOf("."));
		return UUID.randomUUID().toString() + extension;
	}
	
	public static String extractFileNameFromTemporary(String filename) {
		int indexOfSeparator = filename.lastIndexOf(Constant.UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR) + Constant.UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR.length();
		return filename.substring(indexOfSeparator);
	}
	
	
	
}
