package com.snapcrescent.common.utils;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class StringUtils extends org.apache.commons.lang3.StringUtils {

	public static String replaceString(String string, String replace, String replaceWith) {
		return string.replace(replace, replaceWith);
	}

	public static String generateTemporaryFileName(String uploadedFilename) {

		String originalFilename = uploadedFilename.substring(0, uploadedFilename.lastIndexOf("."));
		String extension = uploadedFilename.substring(uploadedFilename.lastIndexOf("."));

		return UUID.randomUUID().toString() + Constant.UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR + originalFilename + extension;
	}

	public static String generateFinalFileName(String temporaryFileName) {
		String extension = temporaryFileName.substring(temporaryFileName.lastIndexOf("."));
		return UUID.randomUUID().toString() + extension;
	}

	public static String extractFileNameFromTemporary(String filename) {
		int indexOfSeparator = filename.lastIndexOf(Constant.UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR);
		int separatorLength = Constant.UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR.length();
		
		if(indexOfSeparator > -1) {
			return filename.substring(indexOfSeparator + separatorLength);	
		} else {
			return filename;
		}
		
	}

	public static String generateDefaultAlbumName(String firstName, String lastName) {
		return firstName + " " + lastName + "'s Album";
	}

	public static long generateHashFromFileName(String fileName) {

		long hash = 0;

		char[] characters = fileName.toCharArray();

		StringBuffer buffer = new StringBuffer();
		for (int i = 0; i < characters.length; i++) {
			buffer.append((int) characters[i]);

			if (i % 4 == 0 || (i == characters.length - 1)) {
				hash = hash + Long.parseLong(buffer.toString());
				buffer = new StringBuffer();
			}
		}

		return hash;
	}

	public static List<Long> idsStringToIdList(String idsString) {
		return Arrays.stream(idsString.split(",")).map(Long::parseLong).collect(Collectors.toList());
	}

}
