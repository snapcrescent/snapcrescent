package com.codeinsight.snap_crescent.common.beans;

import lombok.Data;

@Data
public class BaseResponse {
	
	private Boolean logoutResponse = false;
	private String message;
	
}
