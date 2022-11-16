package com.codeinsight.snap_crescent.config.security;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.security.CoreService;
import com.codeinsight.snap_crescent.common.security.SessionInfo;
import com.codeinsight.snap_crescent.common.security.UserLoginResponse;
import com.codeinsight.snap_crescent.common.utils.JsonUtils;
import com.codeinsight.snap_crescent.common.utils.JwtTokenUtil;

@Component
public class RestLoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
	
	private String ORIGIN = "Origin";

	@Autowired
	private CoreService coreService;
	
	@Autowired
	private JwtTokenUtil jwtTokenUtil;
	
	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
										Authentication authentication) throws ServletException, IOException {

		UserLoginResponse jsonResponse = new UserLoginResponse();
		
		SessionInfo sessionInfo = coreService.getSessionInfo();
		
		jsonResponse.setUser(sessionInfo);
		jsonResponse.setToken(jwtTokenUtil.generateToken(coreService.getAppUser()));
		
		if (request.getHeader(ORIGIN) != null) {

			String origin = request.getHeader(ORIGIN);

			response.setHeader("Access-Control-Allow-Origin", origin);
			response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
			response.setHeader("Access-Control-Allow-Credentials", "true");
			response.setHeader("Access-Control-Allow-Headers",request.getHeader("Access-Control-Request-Headers"));
		}

		response.getWriter().print(JsonUtils.writeJsonString(jsonResponse));
		response.getWriter().flush();
		 
	}
}
