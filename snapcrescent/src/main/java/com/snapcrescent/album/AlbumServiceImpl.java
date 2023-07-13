package com.snapcrescent.album;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.AssetRepository;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant.AlbumType;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.Constant.UserType;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.common.utils.StringUtils;
import com.snapcrescent.thumbnail.UiThumbnail;
import com.snapcrescent.user.UiUser;
import com.snapcrescent.user.User;
import com.snapcrescent.user.UserService;

@Service
public class AlbumServiceImpl extends BaseService implements AlbumService {

	@Autowired
	private AlbumRepository albumRepository;

	@Autowired
	private AlbumConverter albumConverter;

	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;

	@Autowired
	private AssetRepository assetRepository;

	@Autowired
	private UserService userService;
	
	@Override
	@Transactional
	public BaseResponseBean<Long, UiAlbum> search(AlbumSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiAlbum> response = new BaseResponseBean<>();

		int count = albumRepository.count(searchCriteria);

		if (count > 0) {

			List<Album> entities = albumRepository.search(searchCriteria,
					searchCriteria.getResultType() == ResultType.OPTION);
			List<UiAlbum> beans = new ArrayList<UiAlbum>(entities.size());

			for (Album entity : entities) {
				UiAlbum bean = albumConverter.getBeanFromEntity(entity, searchCriteria.getResultType());
				populateAlbumBeanTransientValues(entity, bean);
				beans.add(bean);
			}

			response.setTotalResultsCount(count);
			response.setResultCountPerPage(beans.size());
			response.setCurrentPageIndex(searchCriteria.getPageNumber());

			response.setObjects(beans);

		}

		return response;
	}
	
	@Override
	@Transactional
	public UiAlbum getById(Long id) {
		Album entity = albumRepository.findById(id);
		UiAlbum bean = albumConverter.getBeanFromEntity(entity, ResultType.FULL);
		populateAlbumBeanTransientValues(entity, bean);
		return bean;
	}
	
	@Override
	@Transactional
	public UiAlbum getLiteById(Long id) {
		Album entity = albumRepository.findById(id);
		UiAlbum bean = albumConverter.getBeanFromEntity(entity, ResultType.SEARCH);
		populateAlbumBeanTransientValues(entity, bean);
		return bean;
	}
	
	private void populateAlbumBeanTransientValues(Album entity, UiAlbum bean) {
		if (entity.getCreatedByUserId() == coreService.getAppUser().getId()) {
			bean.setOwnedByMe(true);
		} else {
			bean.setOwnedByMe(false);
		}

		if (albumRepository.countUsersByAlbumId(entity.getId()) > 1) {
			bean.setSharedWithOthers(true);
		} else {
			bean.setSharedWithOthers(false);
		}

		if(entity.getAlbumThumbnail() != null) {
			UiThumbnail thumbnail = bean.getAlbumThumbnail();
			thumbnail.setToken(securedStreamTokenUtil.getSignedAssetStreamToken(entity.getAlbumThumbnail()));	
		}
	}

	@Override
	@Transactional
	public UiAlbum save(UiAlbum bean) throws Exception {
		Album entity = albumConverter.getEntityFromBean(bean);
		albumRepository.save(entity);
		updateAlbumProperties(entity);

		return albumConverter.getBeanFromEntity(entity, ResultType.FULL);
	}

	private void updateAlbumProperties(Album entity) {

	}

	@Override
	@Transactional
	public void update(UiAlbum bean) throws Exception {
		Album entity = albumRepository.findById(bean.getId());

		String password = null;
		
		//Create new user
		if(entity.getPublicAccess() == false && bean.getPublicAccess() == true) {
			UiUser user = new UiUser();
			
			String name = "AlbumPublicAccessUser_" + entity.getId().toString();
			
			user.setFirstName(name);
			user.setLastName(name);
			user.setUsername(name);
			user.setUserType(UserType.PUBLIC_ACCESS.getId());
			user.setPassword(bean.getNewPassword());
			
			user = userService.save(user);
			entity.setPublicAccessUserId(user.getId());
			
			bean.getUsers().add(user);
			
		}
		//Remove user from DB
		else if(entity.getPublicAccess() == true && bean.getPublicAccess() == false) {
			userService.delete(entity.getPublicAccessUserId());
			entity.setPublicAccessUserId(null);
		} 
		//Album owner have changed the password for the album
		else if (entity.getPublicAccess() == true && bean.getPublicAccess() == true && bean.getNewPassword() != null) {
			UiUser user = userService.getById(entity.getPublicAccessUserId());
			user.setPassword(password);
			
			userService.resetPassword(user);
		}
		
		
		albumConverter.populateEntityWithBean(entity, bean);
		updateAlbumProperties(entity);
		albumRepository.save(entity);

	}

	@Override
	@Transactional
	public void createOrUpdateDefaultAlbum(User user) throws Exception {

		String name = StringUtils.generateDefaultAlbumName(user.getFirstName(), user.getLastName());
		Album entity = albumRepository.findDefaultAlbumByUserId(user.getId());

		if (entity == null) {
			entity = new Album();

			entity.setName(name);
			entity.setAlbumType(AlbumType.DEFAULT.getId());
			entity.setCreatedByUserId(user.getId());

			List<User> users = new ArrayList<User>();
			users.add(user);

			entity.setUsers(users);

			albumRepository.save(entity);
		} else {
			entity.setName(name);
			albumRepository.update(entity);
		}
	}

	@Override
	@Transactional
	public void createAlbumAssetAssociation(UiCreateAlbumAssetAssnRequest createAlbumAssetAssnRequest) {

		Long userId = coreService.getAppUser().getId();

		List<Asset> assets = new ArrayList<>(createAlbumAssetAssnRequest.getAssetIds().size());

		for (Long assetId : createAlbumAssetAssnRequest.getAssetIds()) {
			Asset asset = assetRepository.findById(assetId);

			if (asset != null && asset.getCreatedByUserId() == userId) {
				assets.add(asset);
			}
		}

		for (UiAlbum album : createAlbumAssetAssnRequest.getAlbums()) {

			if (album.getId() != null) {
				Album entity = albumRepository.findById(album.getId());

				if (entity != null) {
					if (entity.getCreatedByUserId() == userId) {
						entity.getAssets().addAll(assets);
					}
				}
				
				
				//If no thumbnail is assigned by user then assign the last added asset as thumbnail. 
				if(entity.getAlbumThumbnailId() == null) {
					entity.setAlbumThumbnailId(assets.get(assets.size() - 1).getThumbnailId());
				}

				albumRepository.update(entity);
			} else {
				Album entity = new Album();

				entity.setName(album.getName());
				entity.setAlbumType(AlbumType.CUSTOM.getId());
				entity.setCreatedByUserId(userId);

				List<User> users = new ArrayList<User>();
				users.add(coreService.getUser());
				entity.setUsers(users);

				entity.setAssets(assets);
				
				//it is a new album, hence no thumbnail is assigned by use.
				//Assign the last added asset as thumbnail. 
				entity.setAlbumThumbnailId(assets.get(assets.size() - 1).getThumbnailId());

				albumRepository.save(entity);
			}

		}

	}

	@Override
	@Transactional
	public void updateOrDeleteAlbumPostUserDeletion(Long userId) {
		AlbumSearchCriteria searchCriteria = new AlbumSearchCriteria();
		searchCriteria.setAccessibleByUserId(userId);

		List<Album> entities = albumRepository.search(searchCriteria,
				searchCriteria.getResultType() == ResultType.OPTION);

		for (Album entity : entities) {

			int index = -1;
			for (User albumUser : entity.getUsers()) {
				if (albumUser.getId() == userId) {
					index = entity.getUsers().indexOf(albumUser);
				}
			}

			if (index > -1) {
				entity.getUsers().remove(index);
			}

			albumRepository.update(entity);
		}

		// Second Pass
		// Remove albums created by User

		searchCriteria = new AlbumSearchCriteria();
		searchCriteria.setCreatedByUserId(userId);

		entities = albumRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION);

		for (Album entity : entities) {
			albumRepository.delete(entity);
		}

		albumRepository.flush();
	}
	

}
