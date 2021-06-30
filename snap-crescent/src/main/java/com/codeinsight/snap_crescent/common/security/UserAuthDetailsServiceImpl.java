package com.codeinsight.snap_crescent.common.security;

import java.util.ArrayList;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.user.User;
import com.codeinsight.snap_crescent.user.UserRepository;

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
			appUser = new AppUser(user.getUsername(), user.getPassword(), user.getFirstName(), new ArrayList<>());

			UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(appUser.getUsername(),
					appUser.getPassword(), appUser.getAuthorities());

			auth.setDetails(appUser);
			SecurityContextHolder.getContext().setAuthentication(auth);
		} else {
			throw new UsernameNotFoundException("The username and password you entered don't match.");
		}
		return appUser;
	}

}
