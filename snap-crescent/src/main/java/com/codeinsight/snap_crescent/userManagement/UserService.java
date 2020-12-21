package com.codeinsight.snap_crescent.userManagement;

import com.codeinsight.snap_crescent.userManagement.bean.ResetPasswordRequest;
import com.codeinsight.snap_crescent.userManagement.bean.UserLoginBean;

public interface UserService {

	public User saveUser(User user) throws Exception;

	public User login(UserLoginBean userLoginBean) throws Exception;

	public String resetPassword(ResetPasswordRequest resetPasswordRequest) throws Exception;

	public Boolean doesUserExists() throws Exception;
}
