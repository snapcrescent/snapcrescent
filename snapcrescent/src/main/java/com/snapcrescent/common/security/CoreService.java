package com.snapcrescent.common.security;

import com.snapcrescent.user.User;

public interface CoreService {


	public SessionInfo getSessionInfo();

	public AppUser getAppUser();
	
	public User getUser();

}
