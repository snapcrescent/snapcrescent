package com.snapcrescent.config.security;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.SimpleUrlLogoutSuccessHandler;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.beans.BaseResponse;
import com.snapcrescent.common.utils.JsonUtils;

@Component
public class RestLogoutSuccessHandler extends SimpleUrlLogoutSuccessHandler {

	static final String ORIGIN = "Origin";

	@Override
	public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication)
			throws IOException, ServletException {

		if ("application/json".equals(request.getHeader("Content-Type")) || request.getHeader("Content-Type") == null) {

			if (request.getHeader(ORIGIN) != null) {

				String origin = request.getHeader(ORIGIN);

				response.setHeader("Access-Control-Allow-Origin", origin);
				response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
				response.setHeader("Access-Control-Allow-Credentials", "true");
				response.setHeader("Access-Control-Allow-Headers", request.getHeader("Access-Control-Request-Headers"));
			}

			try {
				String token = request.getHeader("authorization");
				token = token.replaceAll("Bearer", "").trim();
			} catch (Exception e) {
				e.printStackTrace();
			}

			BaseResponse jsonResponse = new BaseResponse();

			response.getWriter().print(JsonUtils.writeJsonString(jsonResponse));
			response.getWriter().flush();
		}

	}

}
