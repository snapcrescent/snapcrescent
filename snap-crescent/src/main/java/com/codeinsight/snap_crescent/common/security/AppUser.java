package com.codeinsight.snap_crescent.common.security;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

public class AppUser extends User {

	private static final long serialVersionUID = -8159744704370912316L;

	public AppUser(String username, String password, String name, Collection<? extends GrantedAuthority> authorities) {
		super(username, password, authorities);
	}

	private Long id;
	private String name;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
