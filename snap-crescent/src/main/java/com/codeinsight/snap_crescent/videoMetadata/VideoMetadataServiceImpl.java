package com.codeinsight.snap_crescent.videoMetadata;

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
public class VideoMetadataServiceImpl implements VideoMetadataService {

	
	@Autowired
	private LocationService locationService;

	public VideoMetadata extractMetaData(String originalFilename, File file) throws Exception {

		Metadata metadata = getMetadata(file);
		Map<String, String> metaDataMap = new HashMap<>();

		for (Directory directory : metadata.getDirectories()) {
			for (Tag tag : directory.getTags()) {
				metaDataMap.put(tag.getTagName(), tag.getDescription());
			}
		}
		VideoMetadata videoMetadata = new VideoMetadata();

		videoMetadata.setName(metaDataMap.get(Constant.METADATA_FILE_NAME));
		videoMetadata.setInternalName(file.getName());
		videoMetadata.setPath(file.getName());
		videoMetadata.setSize(metaDataMap.get(Constant.METADATA_FILE_SIZE));
		String modifiedDateString = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).format(file.lastModified());
		Date modifiedDate = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).parse(modifiedDateString);

		if (metaDataMap.get(Constant.METADATA_CREATED_DATE) != null) {
			videoMetadata.setCreationDatetime(new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT)
					.parse(metaDataMap.get(Constant.METADATA_CREATED_DATE)));
		} else {
			videoMetadata.setCreationDatetime(modifiedDate);
		}
		videoMetadata.setFileTypeName(metaDataMap.get(Constant.METADATA_FILE_TYPE_NAME));
		videoMetadata.setFileTypeLongName(metaDataMap.get(Constant.METADATA_FILE_TYPE_LONG_NAME));
		videoMetadata.setMimeType(metaDataMap.get(Constant.METADATA_MIME_TYPE));
		videoMetadata.setFileExtension(metaDataMap.get(Constant.METADATA_FILE_EXTENSION));
		videoMetadata.setHeight(metaDataMap.get(Constant.METADATA_IMAGE_HEIGHT));
		videoMetadata.setWidth(metaDataMap.get(Constant.METADATA_IMAGE_WIDTH));
		videoMetadata.setModel(metaDataMap.get(Constant.METADATA_MODEL));
		videoMetadata.setFstop(metaDataMap.get(Constant.METADATA_FSTOP));

	    Directory directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
	    int orientation = 1;
	    if(directory != null && directory.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
	    	orientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
	    }
		videoMetadata.setOrientation(orientation);
	    
	    GpsDirectory gpsDirectory = metadata.getFirstDirectoryOfType(GpsDirectory.class);
		
		if(gpsDirectory != null) {
			GeoLocation geoLocation = gpsDirectory.getGeoLocation();
			if (geoLocation != null) {
				Double longitude = geoLocation.getLongitude();
				Double latitude = geoLocation.getLatitude();
				Long locationId = locationService.saveLocation(longitude, latitude);
				videoMetadata.setLocationId(locationId);
			}
		}
		return videoMetadata;
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
