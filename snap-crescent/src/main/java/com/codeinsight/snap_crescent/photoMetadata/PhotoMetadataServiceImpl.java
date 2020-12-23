package com.codeinsight.snap_crescent.photoMetadata;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.utils.Constant;
import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.lang.GeoLocation;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.GpsDirectory;

@Service
public class PhotoMetadataServiceImpl implements PhotoMetadataService {

	public PhotoMetadata extractMetaData(File file) throws Exception {

		Metadata metadata = getMetadata(file);
		Map<String, String> metaDataMap = new HashMap<>();

		for (Directory directory : metadata.getDirectories()) {
			for (Tag tag : directory.getTags()) {
				metaDataMap.put(tag.getTagName(), tag.getDescription());
			}
		}
		PhotoMetadata imageMetadata = new PhotoMetadata();

		imageMetadata.setName(metaDataMap.get(Constant.METADATA_FILE_NAME));
		imageMetadata.setPath(file.getPath());
		imageMetadata.setSize(metaDataMap.get(Constant.METADATA_FILE_SIZE));
		String modifiedDateString = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).format(file.lastModified());
		Date modifiedDate = new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT).parse(modifiedDateString);
		imageMetadata.setModifiedDate(modifiedDate);

		if (metaDataMap.get(Constant.METADATA_CREATED_DATE) != null) {
			imageMetadata.setCreatedDate(new SimpleDateFormat(Constant.SIMPLE_DATE_FORMAT)
					.parse(metaDataMap.get(Constant.METADATA_CREATED_DATE)));
		} else {
			imageMetadata.setCreatedDate(modifiedDate);
		}
		imageMetadata.setFileTypeName(metaDataMap.get(Constant.METADATA_FILE_TYPE_NAME));
		imageMetadata.setFileTypeLongName(metaDataMap.get(Constant.METADATA_FILE_TYPE_LONG_NAME));
		imageMetadata.setMimeType(metaDataMap.get(Constant.METADATA_MIME_TYPE));
		imageMetadata.setFileExtension(metaDataMap.get(Constant.METADATA_FILE_EXTENSION));
		imageMetadata.setHeight(metaDataMap.get(Constant.METADATA_IMAGE_HEIGHT));
		imageMetadata.setWidth(metaDataMap.get(Constant.METADATA_IMAGE_WIDTH));
		imageMetadata.setModel(metaDataMap.get(Constant.METADATA_MODEL));

		Collection<GpsDirectory> gpsDirectories = metadata.getDirectoriesOfType(GpsDirectory.class);
		for (GpsDirectory gpsDirectory : gpsDirectories) {
			GeoLocation geoLocation = gpsDirectory.getGeoLocation();
			imageMetadata.setGeoLocation(geoLocation.toString());
			break;
		}
		return imageMetadata;
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
