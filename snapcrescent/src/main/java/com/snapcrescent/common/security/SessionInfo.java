package com.snapcrescent.common.security;

import lombok.Data;

@Data
public class SessionInfo {

	private Long id;
	private String username;
	private String name;
	
	public SessionInfo(Long id, String username, String name) {
		super();
		this.id = id;
		this.username = username;
		this.name = name;
	}
}
