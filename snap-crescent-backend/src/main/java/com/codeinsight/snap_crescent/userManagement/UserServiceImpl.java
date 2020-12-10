package com.codeinsight.snap_crescent.userManagement;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserRepository userRepository;

	@Override
	public User saveUser(User user) throws DuplicateKeyException {
		User savedUser = null;
		if (!validateUser(user)) {
			throw new DuplicateKeyException("Username already exists.");
		} else {
			savedUser = userRepository.save(user);
		}

		return savedUser;
	}

	private boolean validateUser(User user) {
		boolean exists = userRepository.existsByEmail(user.getEmail());
		return !exists;
	}

}
