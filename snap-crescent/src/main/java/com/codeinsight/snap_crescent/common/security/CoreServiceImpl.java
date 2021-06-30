package com.codeinsight.snap_crescent.common.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class CoreServiceImpl implements CoreService {

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
			sessionInfo = new SessionInfo(appUser.getUsername(), appUser.getName());
		}

		return sessionInfo;
	}

}
