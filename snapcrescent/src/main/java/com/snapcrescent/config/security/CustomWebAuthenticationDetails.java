package com.snapcrescent.config.security;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.security.web.authentication.WebAuthenticationDetails;

import com.snapcrescent.common.security.UserLoginRequest;

public class CustomWebAuthenticationDetails extends WebAuthenticationDetails {

	private static final long serialVersionUID = 4707572641863916710L;
	private UserLoginRequest loginRequest = null;

	public CustomWebAuthenticationDetails(HttpServletRequest request) {
		super(request);
	}

	public UserLoginRequest getLoginRequest() {
		return loginRequest;
	}

	public void setLoginRequest(UserLoginRequest loginRequest) {
		this.loginRequest = loginRequest;
	}

}