package com.codeinsight.snap_crescent.utils;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.beans.AppUser;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

@Component
public class JwtTokenUtil {

	private String JWT_SECRET = "snapCrescent";

	@Value("${jwt.token.expiration}")
	private Long JWT_TOKEN_EXPIRATION;

	public String getUsernameFromToken(String token) {
		return getClaimFromToken(token, Claims::getSubject);
	}

	private Date getExpirationDateFromToken(String token) {
		return getClaimFromToken(token, Claims::getExpiration);
	}

	private <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
		final Claims claims = getAllClaimsFromToken(token);
		return claimsResolver.apply(claims);
	}

	private Claims getAllClaimsFromToken(String token) {
		return Jwts.parser().setSigningKey(JWT_SECRET).parseClaimsJws(token).getBody();
	}

	private Boolean isTokenExpired(String token) {
		final Date expiration = getExpirationDateFromToken(token);
		return expiration.before(new Date());
	}

	public String generateToken(UserDetails userDetails) {
		Map<String, Object> claims = new HashMap<>();
		return createToken(claims, userDetails.getUsername());
	}

	private String createToken(Map<String, Object> claims, String subject) {
		final Date createdDate = new Date();

		return Jwts.builder().setClaims(claims).setSubject(subject).setIssuedAt(createdDate)
				.setExpiration(new Date(createdDate.getTime() + JWT_TOKEN_EXPIRATION * 1000))
				.signWith(SignatureAlgorithm.HS512, JWT_SECRET).compact();
	}

	public Boolean validateToken(String token, UserDetails userDetails) {
		AppUser user = (AppUser) userDetails;
		final String username = getUsernameFromToken(token);

		return (username.equals(user.getUsername()) && !isTokenExpired(token));
	}
}
