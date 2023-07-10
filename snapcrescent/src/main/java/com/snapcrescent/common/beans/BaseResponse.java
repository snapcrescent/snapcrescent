package com.snapcrescent.common.beans;

import lombok.Data;

@Data
public class BaseResponse {
	
	private String message;
	private Boolean success = true;
	
}
