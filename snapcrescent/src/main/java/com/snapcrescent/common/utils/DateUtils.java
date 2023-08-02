package com.snapcrescent.common.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import com.snapcrescent.common.utils.Constant.MetadtaCreatedDateFormat;

public class DateUtils extends org.apache.commons.lang3.time.DateUtils {

	public static String getFilePathFromDate(Date creationDateTime) {
		
		Calendar creationDate = Calendar.getInstance();
		creationDate.setTime(creationDateTime);
		
		String year = "/" + creationDate.get(Calendar.YEAR);
		String month = "/" + String.format("%02d",(creationDate.get(Calendar.MONTH) + 1)) + "/";
		
		return year + month;
		
	}
	
	public static Long getSecondsFromTimeString(String duration) {
		
		long totalSeconds = 0;
		
		try {
			Date date = new SimpleDateFormat("hh:mm:ss").parse(duration);
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(date);
			
			int hours = calendar.get(Calendar.HOUR_OF_DAY);
			int minutes = calendar.get(Calendar.MINUTE);
			int seconds = calendar.get(Calendar.SECOND);
			
			totalSeconds = seconds + (minutes * 60) + (hours * 60 * 60);
		} catch (ParseException e1) {
			
		}
		
		return totalSeconds;
	}
	
	
	public static Date parseCreateDate(String creationDateString) throws ParseException {
		
		List<String> formats = new ArrayList<>();
		
		for (MetadtaCreatedDateFormat metadtaCreatedDateFormat : MetadtaCreatedDateFormat.values()) {
			formats.add(metadtaCreatedDateFormat.getFormat());
		}
		
		Date parsedDate = tryParse(creationDateString, formats);
		
		if(parsedDate == null) {
			throw new ParseException(creationDateString, 0);
		}
		
		return parsedDate;
	
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
