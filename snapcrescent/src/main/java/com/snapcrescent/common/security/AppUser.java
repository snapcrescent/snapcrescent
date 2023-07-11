package com.snapcrescent.common.security;

import java.util.Collection;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import com.snapcrescent.common.utils.Constant.UserType;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class AppUser extends User {

	private static final long serialVersionUID = -8159744704370912316L;
	
	private Long id;
	private String firstName;
	private String lastName;
	private Integer userType;

	public AppUser(Long id, String username, String password, String firstName,String lastName,Integer userType, Collection<? extends GrantedAuthority> authorities) {
		super(username, password, authorities);
		
		this.id = id;
		this.firstName = firstName;
		this.lastName = lastName;
		this.userType = userType;
	}
	
	public boolean isAdmin() {
		return this.userType == UserType.ADMIN.getId();
	}
	
	public boolean isUser() {
		return this.userType == UserType.USER.getId();
	}
}
