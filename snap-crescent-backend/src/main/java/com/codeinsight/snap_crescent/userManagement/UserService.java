package com.codeinsight.snap_crescent.userManagement;

import javax.security.auth.login.CredentialNotFoundException;

import org.springframework.dao.DuplicateKeyException;

import com.codeinsight.snap_crescent.userManagement.bean.ResetPasswordRequest;
import com.codeinsight.snap_crescent.userManagement.bean.UserLoginBean;

public interface UserService {

	public User saveUser(User user) throws DuplicateKeyException;

	public User login(UserLoginBean userLoginBean) throws CredentialNotFoundException;

	public String resetPassword(ResetPasswordRequest resetPasswordRequest) throws CredentialNotFoundException;

	public Boolean doesUserExists() throws Exception;
}
