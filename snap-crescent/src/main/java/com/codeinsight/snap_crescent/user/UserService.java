package com.codeinsight.snap_crescent.user;

import com.codeinsight.snap_crescent.common.beans.ResetPasswordRequest;

public interface UserService {

	public User saveUser(User user) throws Exception;

	public String resetPassword(ResetPasswordRequest resetPasswordRequest) throws Exception;

	public Boolean doesUserExists() throws Exception;
}
