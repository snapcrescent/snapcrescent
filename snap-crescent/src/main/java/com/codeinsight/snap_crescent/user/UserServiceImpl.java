package com.codeinsight.snap_crescent.user;

import java.util.Optional;

import javax.security.auth.login.CredentialNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.codeinsight.snap_crescent.beans.ResetPasswordRequest;
import com.codeinsight.snap_crescent.utils.StringHasher;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserRepository userRepository;

	@Override
	@Transactional
	public User saveUser(User user) throws Exception {
		User savedUser = null;
		if (!validateUser(user)) {
			throw new DuplicateKeyException("Username already exists.");
		} else {
			user.setPassword(StringHasher.getBCrpytHash(user.getPassword()));
			savedUser = userRepository.save(user);
		}

		return savedUser;
	}

	@Override
	@Transactional
	public String resetPassword(ResetPasswordRequest resetPasswordRequest) throws Exception {

		Optional<User> userToRetrive = userRepository.findByUsername(resetPasswordRequest.getUsername());

		if (!userToRetrive.isPresent()) {
			throw new CredentialNotFoundException("User not exist.");
		}

		User user = userToRetrive.get();
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
