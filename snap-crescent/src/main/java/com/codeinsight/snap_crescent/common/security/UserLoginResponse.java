package com.codeinsight.snap_crescent.common.security;

public class UserLoginResponse{

	private SessionInfo user ;
	private String token;

	public SessionInfo getUser() {
		return user;
	}

	public void setUser(SessionInfo user) {
		this.user = user;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}
	
}
