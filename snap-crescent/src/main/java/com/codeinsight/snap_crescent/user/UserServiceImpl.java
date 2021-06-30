package com.codeinsight.snap_crescent.user;

import javax.security.auth.login.CredentialNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.codeinsight.snap_crescent.common.beans.ResetPasswordRequest;
import com.codeinsight.snap_crescent.common.utils.StringHasher;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserRepository userRepository;

	@Override
	@Transactional
	public User saveUser(User user) throws Exception {
		if (!validateUser(user)) {
			throw new DuplicateKeyException("Username already exists.");
		} else {
			user.setPassword(StringHasher.getBCrpytHash(user.getPassword()));
			userRepository.save(user);
		}

		return user;
	}

	@Override
	@Transactional
	public String resetPassword(ResetPasswordRequest resetPasswordRequest) throws Exception {

		User user = userRepository.findByUsername(resetPasswordRequest.getUsername());

		if (user == null) {
			throw new CredentialNotFoundException("User not exist.");
		}

		user.setPassword(StringHasher.getBCrpytHash(resetPasswordRequest.getPassword()));
		userRepository.save(user);

		return "Password successfully updated.";
	}

	private boolean validateUser(User user) {
		boolean exists = userRepository.existsByUsername(user.getUsername());
		return !exists;
	}

	@Override
	public Boolean doesUserExists() throws Exception {
		boolean exists = false;

		if (userRepository.count() > 0) {
			exists = true;
		}

		return exists;
	}

}
