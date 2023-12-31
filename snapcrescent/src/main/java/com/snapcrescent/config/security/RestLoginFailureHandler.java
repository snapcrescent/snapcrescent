package com.snapcrescent.config.security;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.beans.BaseResponse;
import com.snapcrescent.common.utils.JsonUtils;

@Component
public class RestLoginFailureHandler extends SimpleUrlAuthenticationFailureHandler {

	private String ORIGIN = "Origin";

	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException exception) throws ServletException, IOException {

		BaseResponse jsonResponse = new BaseResponse();

		jsonResponse.setMessage(exception.getLocalizedMessage());

		if (exception instanceof BadCredentialsException) {
			jsonResponse.setMessage(
					"Incorrect username or password");
	        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
		}

		if (request.getHeader(ORIGIN) != null) {

			String origin = request.getHeader(ORIGIN);

			response.setHeader("Access-Control-Allow-Origin", origin);
			response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
			response.setHeader("Access-Control-Allow-Credentials", "true");
			response.setHeader("Access-Control-Allow-Headers", request.getHeader("Access-Control-Request-Headers"));
		}
		response.getWriter().print(JsonUtils.writeJsonString(jsonResponse));
		response.getWriter().flush();

	}
}
