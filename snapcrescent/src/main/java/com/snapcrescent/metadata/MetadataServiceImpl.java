package com.snapcrescent.metadata;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.drew.imaging.ImageMetadataReader;
import com.drew.lang.GeoLocation;
import com.drew.metadata.Directory;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.GpsDirectory;
import com.fasterxml.jackson.core.type.TypeReference;
import com.snapcrescent.bulk_import.google.GoogleTakeoutMetadata;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.DateUtils;
import com.snapcrescent.common.utils.FileService;
import com.snapcrescent.common.utils.ImageUtils;
import com.snapcrescent.common.utils.JsonUtils;
import com.snapcrescent.common.utils.StringUtils;
import com.snapcrescent.location.LocationService;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class MetadataServiceImpl extends BaseService implements MetadataService {

	@Autowired
	private LocationService locationService;
	
	@Autowired
	private FileService fileService;

	@Override
	public Metadata createMetadataEntity(File temporaryFile) throws Exception {
		Metadata metadata = new Metadata();
		
		AssetType assetType = FileService.getAssetType(temporaryFile.getName());
		String originalFilename = StringUtils.extractFileNameFromTemporary(temporaryFile.getName());
		
		long assetHash = 0;
		
		if(assetType == AssetType.PHOTO) {
			assetHash = ImageUtils.getPerceptualHash(ImageIO.read(temporaryFile));	
		} else if (assetType == AssetType.VIDEO) {
			assetHash = StringUtils.generateHashFromFileName(originalFilename) + fileService.getFileSize(temporaryFile.getAbsolutePath());	
		}
		
		metadata.setHash(assetHash);
		metadata.setName(originalFilename);
		
		extractMetaData(assetType, temporaryFile, metadata);
		
		return metadata;
	}

	private void extractMetaData(AssetType assetType, File file, Metadata metadata)
			throws Exception {

		try {

			com.drew.metadata.Metadata drewMetadata = ImageMetadataReader.readMetadata(file);

			Map<String, String> metaDataMap = new HashMap<>();

			for (Directory directory : drewMetadata.getDirectories()) {
				for (Tag tag : directory.getTags()) {
					metaDataMap.put(tag.getTagName(), tag.getDescription());
				}
			}

			
			metadata.setInternalName(StringUtils.generateFinalFileName(file.getName()));

			metadata.setSize(Long.parseLong(StringUtils.replaceString(metaDataMap.get(Constant.METADATA_FILE_SIZE),
					Constant.METADATA_FILE_SIZE_VALUE_SUFFIX, "")));
			Date modifiedDate = new Date(file.lastModified());

			String creationDateString = null;

			if (assetType == AssetType.VIDEO) {
				creationDateString = metaDataMap.get(Constant.METADATA_CREATION_TIME);
			}

			if (creationDateString == null) {
				creationDateString = metaDataMap.get(Constant.METADATA_CREATED_DATE);
			}

			if (creationDateString != null) {
				try {
					metadata.setCreationDateTime(DateUtils.parseCreateDate(creationDateString));
				} catch (ParseException e) {
					log.error(e.getLocalizedMessage());
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

			if (assetType == AssetType.PHOTO) {
				metadata.setHeight(Long.parseLong(StringUtils.replaceString(
						metaDataMap.get(Constant.METADATA_IMAGE_HEIGHT), Constant.METADATA_HEIGHT_VALUE_SUFFIX, "")));
				metadata.setWidth(Long.parseLong(StringUtils.replaceString(
						metaDataMap.get(Constant.METADATA_IMAGE_WIDTH), Constant.METADATA_WIDTH_VALUE_SUFFIX, "")));
				
				
				
			} else if (assetType == AssetType.VIDEO) {
				metadata.setHeight(Long.parseLong(StringUtils.replaceString(
						metaDataMap.get(Constant.METADATA_VIDEO_HEIGHT), Constant.METADATA_HEIGHT_VALUE_SUFFIX, "")));
				metadata.setWidth(Long.parseLong(StringUtils.replaceString(
						metaDataMap.get(Constant.METADATA_VIDEO_WIDTH), Constant.METADATA_WIDTH_VALUE_SUFFIX, "")));
			}

			metadata.setModel(metaDataMap.get(Constant.METADATA_MODEL));
			metadata.setFstop(metaDataMap.get(Constant.METADATA_FSTOP));

			String durationInSeconds = metaDataMap.get(Constant.METADATA_DURATION_IN_SECONDS);
			if (durationInSeconds != null) {
				metadata.setDuration(DateUtils.getSecondsFromTimeString(durationInSeconds));
			} else {
				metadata.setDuration(0L);
			}
			
				

			String rotationString = metaDataMap.get(Constant.METADATA_ROTATION);

			if (rotationString != null) {
				Long rotation = Long.parseLong(rotationString);

				if (rotation < 0) {
					rotation = rotation * -1;
				}

				if (rotation % 180 > 0) {
					Long height = metadata.getHeight();

					metadata.setHeight(metadata.getWidth());
					metadata.setWidth(height);
				}
			}

			

			Directory directory = drewMetadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
			int orientation = 1;
			if (directory != null && directory.containsTag(ExifIFD0Directory.TAG_ORIENTATION)) {
				orientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
			}
			metadata.setOrientation(orientation);

			GpsDirectory gpsDirectory = drewMetadata.getFirstDirectoryOfType(GpsDirectory.class);

			if (gpsDirectory != null) {
				GeoLocation geoLocation = gpsDirectory.getGeoLocation();
				if (geoLocation != null) {
					Double longitude = geoLocation.getLongitude();
					Double latitude = geoLocation.getLatitude();
					Long locationId = locationService.saveLocation(longitude, latitude);
					metadata.setLocationId(locationId);
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			log.error(e.getLocalizedMessage());
		}
	}

	@Override
	public Metadata extractMetaDataFromGoogleTakeout(AssetType assetType, File assetFile, File assetJsonFile,
			File temporaryFile) throws Exception {
		Metadata metadata = new Metadata();

		try {

			GoogleTakeoutMetadata googleTakeoutMetadata = JsonUtils.getObjectFromJson(
					new String(Files.readAllBytes(Paths.get(assetJsonFile.getAbsolutePath()))),
					new TypeReference<GoogleTakeoutMetadata>() {
					});

			extractMetaData(assetType, temporaryFile, metadata);

			metadata.setName(googleTakeoutMetadata.getTitle());
			metadata.setCreationDateTime(googleTakeoutMetadata.getCreationDate());
			metadata.setPath(DateUtils.getFilePathFromDate(metadata.getCreationDateTime()));
			Long locationId = locationService.saveLocation(googleTakeoutMetadata.getLongitude(),
					googleTakeoutMetadata.getLatitude());
			metadata.setLocationId(locationId);

		} catch (Exception e) {
			log.error(e.getLocalizedMessage());
		}

		return metadata;
	}
}
