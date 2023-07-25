package com.snapcrescent.common.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.user.UserService;

@Service
public class StartUpOperationsServiceImpl extends BaseService implements StartUpOperationsService {

	@Autowired
	private UserService userService;
	
	@Override
	@Transactional
	public void performPostStartUpOperations() {
		try {
			createOrUpdateDefaultAdmin();
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	
	private void createOrUpdateDefaultAdmin() {
		try {
			userService.createOrUpdateDefaultUser();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
