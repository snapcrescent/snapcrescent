package com.codeinsight.snap_crescent.common.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.codeinsight.snap_crescent.common.utils.Constant.MetadtaCreatedDateFormat;

public class DateUtils extends org.apache.commons.lang3.time.DateUtils {

	public static String getFilePathFromDate(Date creationDateTime) {
		
		Calendar creationDate = Calendar.getInstance();
		creationDate.setTime(creationDateTime);
		
		String year = "/" + creationDate.get(Calendar.YEAR);
		String month = "/" + String.format("%02d",(creationDate.get(Calendar.MONTH) + 1)) + "/";
		
		return year + month;
		
	}
	
	public static Date parseCreateDate(String creationDateString) throws ParseException {
		
		List<String> formats = new ArrayList<>();
		
		for (MetadtaCreatedDateFormat metadtaCreatedDateFormat : MetadtaCreatedDateFormat.values()) {
			formats.add(metadtaCreatedDateFormat.getFormat());
		}
		
		return tryParse(creationDateString, formats);
	
	}
	
	private static Date tryParse(String date, List<String> formats) {
		
		Date creationDate = null;
		SimpleDateFormat parser = null;
		
		for (String format : formats) {
			try {
				parser = new SimpleDateFormat(format);
				creationDate = parser.parse(date);
				break;
			} catch (ParseException e1) {
				
			}
		}
		
		return creationDate;
	}
	
	
	
	
}
