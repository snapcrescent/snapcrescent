package com.codeinsight.snap_crescent.metadata;

import java.io.File;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.common.services.BaseService;
import com.codeinsight.snap_crescent.common.utils.Constant;
import com.codeinsight.snap_crescent.common.utils.DateUtils;
import com.codeinsight.snap_crescent.common.utils.StringUtils;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.location.LocationService;
import com.drew.imaging.ImageMetadataReader;
import com.drew.lang.GeoLocation;
import com.drew.metadata.Directory;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.GpsDirectory;

@Service
public class MetadataServiceImpl extends BaseService implements MetadataService {
	
	@Autowired
	private LocationService locationService;

	public Metadata extractMetaData(AssetType assetType, String originalFilename, File file) throws Exception {
		
		Metadata metadata = new Metadata();

		try {
			
			com.drew.metadata.Metadata drewMetadata = ImageMetadataReader.readMetadata(file);
			
			Map<String, String> metaDataMap = new HashMap<>();

			for (Directory directory : drewMetadata.getDirectories()) {
				for (Tag tag : directory.getTags()) {
					metaDataMap.put(tag.getTagName(), tag.getDescription());
				}
			}
			
			metadata.setName(originalFilename);
			metadata.setInternalName(StringUtils.generateFinalFileName(file.getName()));
			
			metadata.setSize(metaDataMap.get(Constant.METADATA_FILE_SIZE));
			Date modifiedDate = new Date(file.lastModified());

			String creationDateString = metaDataMap.get(Constant.METADATA_CREATED_DATE);
			if (creationDateString != null) {
				try {
					metadata.setCreationDateTime(DateUtils.parseCreateDate(creationDateString));	
				} catch (ParseException e) {
					logger.error(e.getLocalizedMessage());
					metadata.setCreationDateTime(modifiedDate);
				}
				
			} else {
				metadata.setCreationDateTime(modifiedDate);
			}
			
			metadata.setPath(DateUtils.getFilePathFromDate(metadata.getCreationDateTime()));
			
			metadata.setFileTypeName(metaDataMap.get(Constant.METADATA_FILE_TYPE_NAME));
			metadata.setFileTypeLongName(metaDataMap.get(Constant.METADATA_FILE_TYPE_LONG_NAME));
			metadata.setMimeType(metaDataMap.get(Constant.METADATA_MIME_TYPE));
			metadata.setFileExtension(metaDataMap.get(Constant.METADATA_FILE_EXTENSION));
			metadata.setHeight(metaDataMap.get(Constant.METADATA_IMAGE_HEIGHT));
			metadata.setWidth(metaDataMap.get(Constant.METADATA_IMAGE_WIDTH));
			metadata.setModel(metaDataMap.get(Constant.METADATA_MODEL));
			metadata.setFstop(metaDataMap.get(Constant.METADATA_FSTOP));
			
			if(assetType == AssetType.VIDEO) {
				metadata.setDuration(0);
			}

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
			
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage());
		}
		
		return metadata;
	}
}
