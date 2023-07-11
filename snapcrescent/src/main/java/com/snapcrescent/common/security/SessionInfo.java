package com.snapcrescent.common.security;

import lombok.Data;

@Data
public class SessionInfo {

	private Long id;
	private String username;
	private String firstName;
	private String lastName;
	private Integer userType;
	
	public SessionInfo(Long id, String username, String firstName,String lastName, Integer userType) {
		super();
		this.id = id;
		this.username = username;
		this.firstName = firstName;
		this.lastName = lastName;
		this.userType = userType;
	}
}
