package com.codeinsight.snap_crescent.asset;

import org.springframework.http.HttpStatus;

import lombok.Data;

@Data
public class AssetStream {
	
	private String contentType;
	private String acceptRanges;
	private String contentLength;
	private String contentRange;
	private byte[] data;
	HttpStatus httpStatus;

}
