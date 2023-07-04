package com.snapcrescent.user;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.album.AlbumService;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.config.EnvironmentProperties;

@Service
public class UserServiceImpl implements UserService {

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private UserConverter userConverter;

	@Autowired
	private AlbumService albumService;
	
	@Autowired
	private PasswordEncoder passwordEncoder;

	@Transactional
	public BaseResponseBean<Long, UiUser> search(UserSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiUser> response = new BaseResponseBean<>();

		int count = userRepository.count(searchCriteria);

		if (count > 0) {

			List<UiUser> searchResult = userConverter.getBeansFromEntities(
					userRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION),
					searchCriteria.getResultType());

			response.setTotalResultsCount(count);
			response.setResultCountPerPage(searchResult.size());
			response.setCurrentPageIndex(searchCriteria.getPageNumber());

			response.setObjects(searchResult);

		}

		return response;
	}

	@Override
	@Transactional
	public UiUser save(UiUser bean) throws Exception {
		User entity = userConverter.getEntityFromBean(bean);
		userRepository.save(entity);
		updateUserProperties(entity);
		return userConverter.getBeanFromEntity(entity, ResultType.FULL);
	}

	private void updateUserProperties(User entity) throws Exception {
		albumService.createOrUpdateDefaultAlbum(entity);
	}

	@Override
	@Transactional
	public void update(UiUser bean) throws Exception {
		User entity = userRepository.findById(bean.getId());
		userConverter.populateEntityWithBean(entity, bean);
		updateUserProperties(entity);
		userRepository.update(entity);
	}

	@Override
	@Transactional
	public void createOrUpdateDefaultUser() throws Exception {
		
		String password = passwordEncoder.encode(EnvironmentProperties.ADMIN_PASSWORD);
		
		User entity = userRepository.findById(Constant.DEFAULT_ADMIN_USER_ID);
		
		if(entity == null) {
			UiUser bean = new UiUser();
			
			bean.setFirstName("Admin");
			bean.setLastName("User");
			bean.setUsername("admin");
			bean.setActive(true);
			bean.setPassword(password);
			
			
			save(bean);	
		} else {
			updateUserProperties(entity);
			userRepository.updatePasswordByUserId(password, Constant.DEFAULT_ADMIN_USER_ID);
		}
	}
}
