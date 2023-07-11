package com.snapcrescent.common.security;

import java.util.HashSet;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.snapcrescent.common.utils.Constant.UserType;
import com.snapcrescent.user.User;
import com.snapcrescent.user.UserRepository;

import jakarta.transaction.Transactional;

@Service
public class UserAuthDetailsServiceImpl implements UserAuthDetailsService{

	
	@Autowired
	private UserRepository userRepository;
	
	@Override
	@Transactional
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		
		AppUser appUser = null;

		User user = userRepository.findByUsername(username);
		
		if(user != null) {
			appUser = new AppUser(user.getId(), user.getUsername(), user.getPassword(), user.getFirstName(), user.getLastName(), user.getUserType(), getPermissions(user));

			UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(appUser.getUsername(),
					appUser.getPassword(), appUser.getAuthorities());

			auth.setDetails(appUser);
			SecurityContextHolder.getContext().setAuthentication(auth);
		} else {
			throw new UsernameNotFoundException("The username and password you entered don't match.");
		}
		return appUser;
	}
	
	private Set<SimpleGrantedAuthority> getPermissions(User user)  {

		Set<SimpleGrantedAuthority> simplePermissions = new HashSet<SimpleGrantedAuthority>();

		
		if(user.getUserType() == UserType.ADMIN.getId()) {
			simplePermissions.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
		}
		
		if(user.getUserType() == UserType.USER.getId()) {
			simplePermissions.add(new SimpleGrantedAuthority("ROLE_USER"));
		}
		
		return simplePermissions;
	}

}
