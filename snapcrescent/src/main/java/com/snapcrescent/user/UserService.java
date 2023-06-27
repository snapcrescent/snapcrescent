package com.snapcrescent.user;

import com.snapcrescent.common.beans.ResetPasswordRequest;

public interface UserService {

	public User saveUser(User user) throws Exception;

	public String resetPassword(ResetPasswordRequest resetPasswordRequest) throws Exception;

	public Boolean doesUserExists() throws Exception;
}
