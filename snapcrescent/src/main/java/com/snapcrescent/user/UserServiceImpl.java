package com.snapcrescent.user;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.album.AlbumService;
import com.snapcrescent.asset.AssetService;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.utils.Constant;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.Constant.UserType;
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
	private AssetService assetService;
	
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
		entity.setPassword(passwordEncoder.encode(entity.getPassword()));
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
		String password = entity.getPassword();
		userConverter.populateEntityWithBean(entity, bean);
		entity.setPassword(password);
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
			bean.setPassword(password);
			bean.setUserType(UserType.ADMIN.getId());
			
			
			save(bean);	
		} else {
			entity.setUserType(UserType.ADMIN.getId());
			entity.setActive(true);
			updateUserProperties(entity);
			userRepository.updatePasswordByUserId(password, Constant.DEFAULT_ADMIN_USER_ID);
		}
	}

	@Override
	@Transactional
	public UiUser getById(Long id) {
		return userConverter.getBeanFromEntity(userRepository.findById(id), ResultType.FULL);
	}

	@Override
	@Transactional
	public void delete(Long id) throws Exception {
		albumService.updateOrDeleteAlbumPostUserDeletion(id);
		assetService.deleteAssetPostUserDeletion(id);
		userRepository.delete(id);
	}

	@Override
	@Transactional
	public void resetPassword(UiUser bean) throws Exception {
		User entity = userRepository.findById(bean.getId());
		userConverter.populateEntityWithBean(entity, bean);
		entity.setPassword(passwordEncoder.encode(entity.getPassword()));
		updateUserProperties(entity);
		userRepository.update(entity);
		
	}
}
