package com.snapcrescent.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

@Component
public class UserValidator implements Validator {
	
	@Autowired
	private UserRepository userRepository;

	@Override
	public boolean supports(Class<?> clazz) {
		return UiUser.class.equals(clazz);
	}

	@Override
	@Transactional
	public void validate(Object target, Errors errors) {
		UiUser bean = (UiUser) target;
		
		User persistedEntity = userRepository.findByUsername(bean.getUsername());
		
		if(persistedEntity != null) {
			if(bean.getId() == null || bean.getId() != null && !persistedEntity.getId().equals(bean.getId())) {
				errors.rejectValue("username", "usernameAlreadyUsed");
			}
		}

	}

}
