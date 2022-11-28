package com.codeinsight.snap_crescent.common.utils;

public class Constant {

	public static final String DEMO_ADDRESS = "demo.snapcrescent.com";
	public static final String DB_MYSQL = "MYSQL";
	public static final String DB_SQLITE = "SQLITE";
	
	public static final String UPLOAD_FILE_NAME_TEMPORARY_SEPARATOR = "FILE_NAME_SEPARATOR";

	public static final String METADATA_FILE_NAME = "File Name";
	public static final String METADATA_FILE_SIZE = "File Size";
	public static final String METADATA_FILE_MODIFIED_DATE = "File Modified Date";
	public static final String METADATA_FILE_TYPE_NAME = "Detected File Type Name";
	public static final String METADATA_FILE_TYPE_LONG_NAME = "Detected File Type Long Name";
	public static final String METADATA_MIME_TYPE = "Detected MIME Type";
	public static final String METADATA_FILE_EXTENSION = "Expected File Name Extension";
	public static final String METADATA_IMAGE_HEIGHT = "Image Height";
	public static final String METADATA_IMAGE_WIDTH = "Image Width";
	public static final String METADATA_CREATED_DATE = "Date/Time";
	public static final String METADATA_CREATION_TIME = "Creation Time";
	
	public static final String METADATA_MODEL = "Model";
	public static final String METADATA_FSTOP = "F-Number";
	public static final String METADATA_DURATION = "Duration";
	
	public static final String UNPROCESSED_ASSET_FOLDER = "un-processed/";
	
	public static final String PHOTO_FOLDER = "/photos/";
	public static final String VIDEO_FOLDER = "/videos/";
	public static final String THUMBNAIL_FOLDER = "/thumbnails/";

	public static final String SIMPLE_DATE_FORMAT = "yyyy:MM:dd hh:mm:ss";
	
	public enum MetadtaCreatedDateFormat {
		FORMAT_1("yyyy:MM:dd hh:mm:ss"),
		FORMAT_2("yyyy:MM:dd HH:mm:ss"),
		FORMAT_3("yyyy-MM-dd hh:mm:ss"),
		FORMAT_4("yyyy-MM-dd HH:mm:ss"),
		FORMAT_5("dd-MM-yyyy HH:mm"),
		FORMAT_6("EEE MMM dd HH:mm:ss XXX yyyy");
		
		
		private String format;
		
		private MetadtaCreatedDateFormat(String format) {
			this.format = format;
		}
		
		public String getFormat() {
			return format;
		}
		
	}
	
	
	public static final String VIDEO = "/video";

    public static final String CONTENT_TYPE = "Content-Type";
    public static final String CONTENT_LENGTH = "Content-Length";
    public static final String VIDEO_CONTENT = "video/";
    public static final String CONTENT_RANGE = "Content-Range";
    public static final String ACCEPT_RANGES = "Accept-Ranges";
    public static final String BYTES = "bytes";
    public static final int CHUNK_SIZE = 524288; //512KB
    
    
    public interface DbEnum {
		int getId();
		String getLabel();
	}
    
    public enum AssetType implements DbEnum {
    	PHOTO(1,"Photo"),
    	VIDEO(2, "Video");
		
		private int id;
		private String label;
		
		private AssetType(int id, String label) {
			this.id = id;
			this.label = label;
		}
		
		@Override
		public int getId() {
			return this.id;
		}
		
		@Override
		public String getLabel() {
			return this.label;
		}
		
		public static AssetType findById(int id) {
			
			for (AssetType item : AssetType.values()) {
				if(item.getId() == id) {
					return item;
				}
			}
			
			return null;
		}
	}
	
	
	public static enum FILE_TYPE {
		PHOTO, VIDEO, THUMBNAIL
	}
	
	public enum ResultType {
		OPTION, SEARCH, FULL;
	}

}
