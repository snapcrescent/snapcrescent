package com.snapcrescent.bulk_import.google;


import java.text.ParseException;
import java.util.Date;

import com.snapcrescent.common.utils.DateUtils;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class GoogleTakeoutMetadata  {

	String title;
	GoogleTakeoutAssetDateTime photoTakenTime;
	GeoData geoData;
	
	public Date getCreationDate() {
		try {
			return DateUtils.parseCreateDate(photoTakenTime.getFormatted());
		} catch (ParseException e) {
			e.printStackTrace();
			return new Date();
		}
	}
	
	public Double getLongitude() {
		return geoData.getLongitude();
	}
	
	public Double getLatitude() {
		return geoData.getLongitude();
	}
}

@Data
class GoogleTakeoutAssetDateTime {
	Long timestamp;
	String formatted;
}

@Data
class GeoData {
	Double latitude;
	Double longitude;
	Double altitude;
}
