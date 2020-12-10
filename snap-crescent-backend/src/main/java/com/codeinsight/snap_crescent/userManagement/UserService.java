package com.codeinsight.snap_crescent.userManagement;

import org.springframework.dao.DuplicateKeyException;

public interface UserService {

	public User saveUser(User user) throws DuplicateKeyException;
}
