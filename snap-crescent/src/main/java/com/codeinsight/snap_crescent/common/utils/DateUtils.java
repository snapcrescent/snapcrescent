package com.codeinsight.snap_crescent.common.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateUtils extends org.apache.commons.lang3.time.DateUtils {

	public static String getFilePathFromDate(Date creationDateTime) {
		
		Calendar creationDate = Calendar.getInstance();
		creationDate.setTime(creationDateTime);
		
		String year = "/" + creationDate.get(Calendar.YEAR);
		String month = "/" + String.format("%02d",(creationDate.get(Calendar.MONTH) + 1)) + "/";
		
		return year + month;
		
	}
	
	public static Date parseCreateDate(String creationDateString) throws ParseException {
		
		Date creationDate = null;
		SimpleDateFormat parser = null;
		
		try {
			parser = new SimpleDateFormat(Constant.METADATA_CREATED_DATE_FORMAT_1);
			creationDate = parser.parse(creationDateString);
		} catch (ParseException e1) {
			
			try {
				parser = new SimpleDateFormat(Constant.METADATA_CREATED_DATE_FORMAT_2);
				creationDate = parser.parse(creationDateString);
			} catch (ParseException e2) {
					
				try {
					parser = new SimpleDateFormat(Constant.METADATA_CREATED_DATE_FORMAT_3);
					creationDate = parser.parse(creationDateString);
				} catch (ParseException e3) {
					try {
						parser = new SimpleDateFormat(Constant.METADATA_CREATED_DATE_FORMAT_4);
						creationDate = parser.parse(creationDateString);
					} catch (ParseException e4) {
						throw e4;	
					}	
				}
			}
			
		}
		
		return creationDate;
	}
	
	
}
