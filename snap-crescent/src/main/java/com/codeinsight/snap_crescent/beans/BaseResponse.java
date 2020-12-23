package com.codeinsight.snap_crescent.beans;

public class BaseResponse {
	
	private Boolean logoutResponse = false;
	private String message;

	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	
	public Boolean getLogoutResponse() {
		return logoutResponse;
	}
	public void setLogoutResponse(Boolean logoutResponse) {
		this.logoutResponse = logoutResponse;
	}	
}
