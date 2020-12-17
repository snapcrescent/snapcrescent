package com.codeinsight.snap_crescent.beans;

public class BaseResponse {
	
	private Boolean logoutResponse = false;
	private AppUser appUser = null;
	private Boolean success = false;
	private String message;

	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public Boolean getSuccess() {
		return success;
	}
	public void setSuccess(Boolean success) {
		this.success = success;
	}
	
	public Boolean getLogoutResponse() {
		return logoutResponse;
	}
	public void setLogoutResponse(Boolean logoutResponse) {
		this.logoutResponse = logoutResponse;
	}
	public AppUser getAppUser() {
		return appUser;
	}
	public void setAppUser(AppUser appUser) {
		this.appUser = appUser;
	}	
}
