package com.snapcrescent.common.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.user.User;
import com.snapcrescent.user.UserRepository;

@Service
public class CoreServiceImpl implements CoreService {
	
	@Autowired
	private UserRepository userRepository;

	@Override
	public AppUser getAppUser() {

		AppUser appUser = null;
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();

		if (auth != null) {

			Object authObject = auth.getPrincipal();

			if (authObject != null && authObject instanceof String) {
				authObject = auth.getDetails();
			}
			if (authObject != null && authObject instanceof AppUser) {
				appUser = (AppUser) authObject;
			}

		}

		return appUser;
	}

	@Override
	public SessionInfo getSessionInfo() {

		SessionInfo sessionInfo = null;

		AppUser appUser = getAppUser();

		if (appUser != null) {
			sessionInfo = new SessionInfo(appUser.getId(), appUser.getUsername(), appUser.getName());
		}

		return sessionInfo;
	}

	@Override
	@Transactional
	public User getUser() {
		return userRepository.findById(getAppUser().getId());
	}

}
