package com.codeinsight.snap_crescent.security;

import java.util.ArrayList;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.codeinsight.snap_crescent.beans.AppUser;
import com.codeinsight.snap_crescent.user.User;
import com.codeinsight.snap_crescent.user.UserRepository;

@Service
public class UserAuthDetailsServiceImpl implements UserAuthDetailsService{

	
	@Autowired
	private UserRepository userRepository;
	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		
		AppUser appUser = null;

		Optional<User> userOpt = userRepository.findByUsername(username);
		
		if(userOpt.isPresent()) {
			User user = userOpt.get();
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
