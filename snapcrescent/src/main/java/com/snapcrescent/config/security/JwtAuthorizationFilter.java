package com.snapcrescent.config.security;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.snapcrescent.common.security.UserAuthDetailsService;
import com.snapcrescent.common.utils.JwtTokenUtil;

import io.jsonwebtoken.ExpiredJwtException;

@Component
public class JwtAuthorizationFilter extends OncePerRequestFilter {
	
	private final String JWT_HEADER = "Authorization";
	private final String JWT_HEADER_PREFIX = "Bearer";

	@Autowired
	private UserAuthDetailsService userDetailsService;
	
	@Autowired
	private JwtTokenUtil jwtTokenUtil;

	@Override
	protected void doFilterInternal(HttpServletRequest req, HttpServletResponse res, FilterChain chain)
			throws IOException, ServletException {
		
		String token = "";
		
		try {		
			String header = req.getHeader(JWT_HEADER);
			
			if(header != null && header.startsWith(JWT_HEADER_PREFIX)) {
				token = header.replaceAll(JWT_HEADER_PREFIX, "").trim();
			}
			
			if (token.isEmpty()) {
				chain.doFilter(req, res);
				return;
			}
		} catch (NullPointerException e) {
				chain.doFilter(req, res);
				return;
		}
		
		try {
			UsernamePasswordAuthenticationToken authentication = getAuthentication(token);

			SecurityContextHolder.getContext().setAuthentication(authentication);

		} catch (ExpiredJwtException e) {
			logger.error(e);
			res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "The token is expired.");
		}
		chain.doFilter(req, res);
	}

	private UsernamePasswordAuthenticationToken getAuthentication(String token) {
		
			String user = jwtTokenUtil.getUsernameFromToken(token);

			UserDetails userDetails = userDetailsService.loadUserByUsername(user);

			if (user != null) {

				UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
						userDetails.getUsername(), userDetails.getPassword(), userDetails.getAuthorities());

				auth.setDetails(userDetails);

				return auth;
			}

		return null;
	}

}
