package com.codeinsight.snap_crescent.metadata;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.bulk_import.google.GoogleTakeoutMetadata;
import com.codeinsight.snap_crescent.common.services.BaseService;
import com.codeinsight.snap_crescent.common.utils.Constant;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.common.utils.DateUtils;
import com.codeinsight.snap_crescent.common.utils.JsonUtils;
import com.codeinsight.snap_crescent.common.utils.StringUtils;
import com.codeinsight.snap_crescent.location.LocationService;
import com.drew.imaging.ImageMetadataReader;
import com.drew.lang.GeoLocation;
import com.drew.metadata.Directory;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.GpsDirectory;
import com.fasterxml.jackson.core.type.TypeReference;

@Service
public class MetadataServiceImpl extends BaseService implements MetadataService {
	
	@Autowired
	private LocationService locationService;
	
	@Override
	public Metadata computeMetaData(AssetType assetType, String originalFilename, File file) throws Exception {
		Metadata metadata = new Metadata();
		extractMetaData(assetType, originalFilename, file, metadata);
		return metadata;
	}
	
	@Override
	public void recomputeMetaData(AssetType assetType, Metadata metadata, File file) throws Exception {
		String internalName = metadata.getInternalName();
		String path = metadata.getPath();
		extractMetaData(assetType, metadata.getName(), file, metadata);
		metadata.setInternalName(internalName);
		metadata.setPath(path);
	}

	private void extractMetaData(AssetType assetType, String originalFilename, File file, Metadata metadata) throws Exception {
		
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
			
			String sizeString = metaDataMap.get(Constant.METADATA_FILE_SIZE);
			sizeString = sizeString.replace(Constant.METADATA_FILE_SIZE_VALUE_SUFFIX, "").trim();
			
			metadata.setSize(Long.parseLong(sizeString));
			Date modifiedDate = new Date(file.lastModified());
			
			
			String creationDateString = null;
			
			if(assetType == AssetType.VIDEO) {
				creationDateString = metaDataMap.get(Constant.METADATA_CREATION_TIME);
			}
			
			if(creationDateString == null) {
				creationDateString = metaDataMap.get(Constant.METADATA_CREATED_DATE);
			}
			
			
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
				String duration = metaDataMap.get(Constant.METADATA_DURATION);
					if(duration != null) {
						metadata.setDuration(Long.parseLong(duration)/1000);			
					}
				
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
	}

	@Override
	public Metadata extractMetaDataFromGoogleTakeout(AssetType assetType, File assetFile, File assetJsonFile, File temporaryFile) throws Exception {
			Metadata metadata = new Metadata();
			
			try {
			
			GoogleTakeoutMetadata googleTakeoutMetadata = JsonUtils.getObjectFromJson(new String(Files.readAllBytes(Paths.get(assetJsonFile.getAbsolutePath()))),  new TypeReference<GoogleTakeoutMetadata>() {});
			
			extractMetaData(assetType, googleTakeoutMetadata.getTitle(), temporaryFile, metadata);
			
			metadata.setName(googleTakeoutMetadata.getTitle());
			metadata.setCreationDateTime(googleTakeoutMetadata.getCreationDate());
			metadata.setPath(DateUtils.getFilePathFromDate(metadata.getCreationDateTime()));
			Long locationId = locationService.saveLocation(googleTakeoutMetadata.getLongitude(), googleTakeoutMetadata.getLatitude());
			metadata.setLocationId(locationId);
			
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage());
		}
			
		return metadata;
	}
}
