package com.snapcrescent.config.security;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.beans.BaseResponse;
import com.snapcrescent.common.utils.JsonUtils;

@Component
public class RestLoginEntryPoint implements AuthenticationEntryPoint{
		
static final String ORIGIN = "Origin";
	
	@Override
	public void commence(HttpServletRequest request, HttpServletResponse response,  AuthenticationException authenticationException) 
			throws IOException, ServletException{
		
		if ("application/json".equals(request.getHeader("Content-Type"))) {
			
			BaseResponse jsonResponse = new BaseResponse();
			
			response.setHeader("Access-Control-Allow-Origin", request.getHeader("Origin"));
			response.setHeader("Access-Control-Allow-Credentials", "true");
	        response.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, OPTIONS, DELETE");
	        response.setHeader("Access-Control-Max-Age", "3600");
	        response.setHeader("Access-Control-Allow-Headers", "x-requested-with, Content-Type, origin, authorization, accept, client-security-token");
	        
	        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			
			response.getWriter().print(JsonUtils.writeJsonString(jsonResponse));
			response.getWriter().flush();
		}
		else {
			
			
			BaseResponse jsonResponse = new BaseResponse();
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			
			response.getWriter().print(JsonUtils.writeJsonString(jsonResponse));
			response.getWriter().flush();
			
		}
	}
}