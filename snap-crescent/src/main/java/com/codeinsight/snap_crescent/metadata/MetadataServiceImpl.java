package com.codeinsight.snap_crescent.metadata;

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
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.GpsDirectory;

@Service
public class MetadataServiceImpl implements MetadataService {

	
	@Autowired
	private LocationService locationService;

	public Metadata extractMetaData(String originalFilename, File file) throws Exception {

		com.drew.metadata.Metadata drewMetadata = getMetadata(file);
		
		Map<String, String> metaDataMap = new HashMap<>();

		for (Directory directory : drewMetadata.getDirectories()) {
			for (Tag tag : directory.getTags()) {
				metaDataMap.put(tag.getTagName(), tag.getDescription());
			}
		}
		Metadata metadata = new Metadata();
		
		
		metadata.setName(originalFilename);
		metadata.setInternalName(file.getName());
		metadata.setPath("");
		metadata.setSize(metaDataMap.get(Constant.METADATA_FILE_SIZE));
		Date modifiedDate = new Date(file.lastModified());

		if (metaDataMap.get(Constant.METADATA_CREATED_DATE) != null) {
			metadata.setCreationDatetime(new SimpleDateFormat(Constant.METADATA_CREATED_DATE_FORMAT)
					.parse(metaDataMap.get(Constant.METADATA_CREATED_DATE)));
		} else {
			metadata.setCreationDatetime(modifiedDate);
		}
		metadata.setFileTypeName(metaDataMap.get(Constant.METADATA_FILE_TYPE_NAME));
		metadata.setFileTypeLongName(metaDataMap.get(Constant.METADATA_FILE_TYPE_LONG_NAME));
		metadata.setMimeType(metaDataMap.get(Constant.METADATA_MIME_TYPE));
		metadata.setFileExtension(metaDataMap.get(Constant.METADATA_FILE_EXTENSION));
		metadata.setHeight(metaDataMap.get(Constant.METADATA_IMAGE_HEIGHT));
		metadata.setWidth(metaDataMap.get(Constant.METADATA_IMAGE_WIDTH));
		metadata.setModel(metaDataMap.get(Constant.METADATA_MODEL));
		metadata.setFstop(metaDataMap.get(Constant.METADATA_FSTOP));

	    Directory directory = drewMetadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
	    int orientation = 1;
	    if(directory != null && directory.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
	    	orientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
	    }
		metadata.setOrientation(orientation);
	    
	    GpsDirectory gpsDirectory = drewMetadata.getFirstDirectoryOfType(GpsDirectory.class);
		
		if(gpsDirectory != null) {
			GeoLocation geoLocation = gpsDirectory.getGeoLocation();
			if (geoLocation != null) {
				Double longitude = geoLocation.getLongitude();
				Double latitude = geoLocation.getLatitude();
				Long locationId = locationService.saveLocation(longitude, latitude);
				metadata.setLocationId(locationId);
			}
		}
		return metadata;
	}

	private com.drew.metadata.Metadata getMetadata(File file) {

		com.drew.metadata.Metadata metadata = null;
		try {
			metadata = ImageMetadataReader.readMetadata(file);

		} catch (ImageProcessingException | IOException e) {
			e.printStackTrace();
		}

		return metadata;
	}
}
