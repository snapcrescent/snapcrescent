package com.snapcrescent.config.security;

import java.io.BufferedReader;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.fasterxml.jackson.core.type.TypeReference;
import com.snapcrescent.common.security.UserLoginRequest;
import com.snapcrescent.common.utils.JsonUtils;

public class RestUsernamePasswordAuthenticationFilter extends UsernamePasswordAuthenticationFilter {

	static final String ORIGIN = "Origin";

	@Override
	public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
			throws AuthenticationException {

		UserLoginRequest loginRequest = null;

		try {
			loginRequest = parseLoginData(request);
		} catch (Exception e) {
			throw new AuthenticationServiceException(e.getLocalizedMessage());
		}

		UsernamePasswordAuthenticationToken authRequest = new UsernamePasswordAuthenticationToken(
				loginRequest.getUsername(), loginRequest.getPassword());

		setDetails(request, authRequest);
		if (authRequest.getDetails() instanceof CustomWebAuthenticationDetails) {
			CustomWebAuthenticationDetails webAuthDetails = (CustomWebAuthenticationDetails) authRequest.getDetails();
			webAuthDetails.setLoginRequest(loginRequest);
		}
		return this.getAuthenticationManager().authenticate(authRequest);
	}

	private UserLoginRequest parseLoginData(HttpServletRequest request) throws Exception {
		StringBuffer requestBodyString = new StringBuffer();

		String line = null;

		BufferedReader reader = request.getReader();

		while ((line = reader.readLine()) != null) {
			requestBodyString.append(line);
		}

		return JsonUtils.getObjectFromJson(requestBodyString.toString(), new TypeReference<UserLoginRequest>() {
		});
	}
}
