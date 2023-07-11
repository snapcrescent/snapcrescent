package com.snapcrescent.user;

import com.snapcrescent.common.beans.BaseResponseBean;

public interface UserService {

	public BaseResponseBean<Long, UiUser> search(UserSearchCriteria searchCriteria);
	public UiUser getById(Long id);
	public UiUser save(UiUser user) throws Exception;
	public void update(UiUser user) throws Exception;
	public void resetPassword(UiUser user) throws Exception;
	public void delete(Long id) throws Exception;
	void createOrUpdateDefaultUser() throws Exception;
}
