package com.snapcrescent.common.security;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class AppUser extends User {

	private static final long serialVersionUID = -8159744704370912316L;
	
	private Long id;
	private String name;

	public AppUser(Long id, String username, String password, String name, Collection<? extends GrantedAuthority> authorities) {
		super(username, password, authorities);
		
		this.id = id;
		this.name = name;
	}
}
