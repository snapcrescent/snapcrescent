package com.codeinsight.snap_crescent.photoMetadata;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.common.utils.Constant;
import com.codeinsight.snap_crescent.location.LocationService;
import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.lang.GeoLocation;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.GpsDirectory;

@Service
public class PhotoMetadataServiceImpl implements PhotoMetadataService {

	
	@Autowired
	private LocationService locationService;

	public PhotoMetadata extractMetaData(String originalFilename, File file) throws Exception {

		Metadata metadata = getMetadata(file);
		Map<String, String> metaDataMap = new HashMap<>();

		for (Directory directory : metadata.getDirectories()) {
			for (Tag tag : directory.getTags()) {
				metaDataMap.put(tag.getTagName(), tag.getDescription());
			}
		}
		PhotoMetadata photoMetadata = new PhotoMetadata();

		photoMetadata.setName(metaDataMap.get(Constant.METADATA_FILE_NAME));
		photoMetadata.setInternalName(file.getName());
		photoMetadata.setPath(file.getName());
		photoMetadata.setSize(metaDataMap.get(Constant.METADATA_FILE_SIZE));
		String modifiedDateString = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).format(file.lastModified());
		Date modifiedDate = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).parse(modifiedDateString);

		if (metaDataMap.get(Constant.METADATA_CREATED_DATE) != null) {
			photoMetadata.setCreationDatetime(new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT)
					.parse(metaDataMap.get(Constant.METADATA_CREATED_DATE)));
		} else {
			photoMetadata.setCreationDatetime(modifiedDate);
		}
		photoMetadata.setFileTypeName(metaDataMap.get(Constant.METADATA_FILE_TYPE_NAME));
		photoMetadata.setFileTypeLongName(metaDataMap.get(Constant.METADATA_FILE_TYPE_LONG_NAME));
		photoMetadata.setMimeType(metaDataMap.get(Constant.METADATA_MIME_TYPE));
		photoMetadata.setFileExtension(metaDataMap.get(Constant.METADATA_FILE_EXTENSION));
		photoMetadata.setHeight(metaDataMap.get(Constant.METADATA_IMAGE_HEIGHT));
		photoMetadata.setWidth(metaDataMap.get(Constant.METADATA_IMAGE_WIDTH));
		photoMetadata.setModel(metaDataMap.get(Constant.METADATA_MODEL));
		photoMetadata.setFstop(metaDataMap.get(Constant.METADATA_FSTOP));

	    Directory directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
	    int orientation = 1;
	    if(directory != null && directory.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
	    	orientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
	    }
		photoMetadata.setOrientation(orientation);
	    
	    GpsDirectory gpsDirectory = metadata.getFirstDirectoryOfType(GpsDirectory.class);
		
		if(gpsDirectory != null) {
			GeoLocation geoLocation = gpsDirectory.getGeoLocation();
			if (geoLocation != null) {
				Double longitude = geoLocation.getLongitude();
				Double latitude = geoLocation.getLatitude();
				Long locationId = locationService.saveLocation(longitude, latitude);
				photoMetadata.setLocationId(locationId);
			}
		}
		return photoMetadata;
	}

	private Metadata getMetadata(File file) {

		Metadata metadata = null;
		try {
			metadata = ImageMetadataReader.readMetadata(file);

		} catch (ImageProcessingException | IOException e) {
			e.printStackTrace();
		}

		return metadata;
	}
}
