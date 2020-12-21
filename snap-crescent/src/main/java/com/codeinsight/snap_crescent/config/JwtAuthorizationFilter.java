package com.codeinsight.snap_crescent.config;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import com.codeinsight.snap_crescent.security.UserAuthDetailsService;
import com.codeinsight.snap_crescent.utils.JwtTokenUtil;

import io.jsonwebtoken.ExpiredJwtException;

public class JwtAuthorizationFilter extends BasicAuthenticationFilter {

	@Autowired
	private UserAuthDetailsService userDetailsService;
	
	@Autowired
	private JwtTokenUtil jwtTokenUtil;

	@Value("${jwt.header}")
	private String JWT_HEADER;

	@Value("${jwt.header.prefix}")
	private String JWT_HEADER_PREFIX;

	public JwtAuthorizationFilter(AuthenticationManager authManager) {
		super(authManager);
	}

	@Override
	protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
			throws IOException, ServletException {
		String header = req.getHeader(JWT_HEADER);

		if (header == null || !header.startsWith(JWT_HEADER_PREFIX)) {
			chain.doFilter(req, res);
			return;
		}
		try {
			UsernamePasswordAuthenticationToken authentication = getAuthentication(req);

			SecurityContextHolder.getContext().setAuthentication(authentication);

		} catch (ExpiredJwtException e) {
			logger.error(e);
			res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "The token is expired.");
		}
		chain.doFilter(req, res);
	}

	private UsernamePasswordAuthenticationToken getAuthentication(HttpServletRequest request) {
		try {
			String token = request.getHeader(JWT_HEADER);
			token = token.replaceAll("Bearer", "").trim();
			

			String user = jwtTokenUtil.getUsernameFromToken(token.replace(JWT_HEADER_PREFIX, ""));

			UserDetails userDetails = userDetailsService.loadUserByUsername(user);

			if (user != null) {

				UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
						userDetails.getUsername(), userDetails.getPassword(), userDetails.getAuthorities());

				auth.setDetails(userDetails);

				return auth;
			}

		} catch (Exception e) {
		}

		return null;
	}

}
