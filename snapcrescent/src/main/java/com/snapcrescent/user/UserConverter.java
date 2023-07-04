package com.snapcrescent.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.snapcrescent.common.BaseConverter;

@Component
public class UserConverter extends BaseConverter<User, UiUser> {

	@Autowired
	private UserRepository userRepository;
	
	public UserConverter() {
		super(User.class, UiUser.class);
	}

	@Override
	public User loadEntityById(Long id) {
		return userRepository.loadById(id);
	}
}
