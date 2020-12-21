package com.codeinsight.snap_crescent.security;

import com.codeinsight.snap_crescent.beans.AppUser;
import com.codeinsight.snap_crescent.beans.SessionInfo;

public interface CoreService {


	public SessionInfo getSessionInfo();

	public AppUser getAppUser();

}
