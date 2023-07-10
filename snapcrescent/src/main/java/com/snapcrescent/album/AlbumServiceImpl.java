package com.snapcrescent.album;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.AssetRepository;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.Constant.AlbumType;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.common.utils.StringUtils;
import com.snapcrescent.thumbnail.ThumbnailConverter;
import com.snapcrescent.thumbnail.UiThumbnail;
import com.snapcrescent.user.User;

@Service
public class AlbumServiceImpl extends BaseService implements AlbumService {

	@Autowired
	private AlbumRepository albumRepository;

	@Autowired
	private AlbumConverter albumConverter;

	@Autowired
	private ThumbnailConverter thumbnailConverter;

	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;

	@Autowired
	private AssetRepository assetRepository;

	@Autowired
	private PasswordEncoder passwordEncoder;

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

				if (entity.getAssets().size() > 0) {
					Asset lastAddedAsset = entity.getAssets().get(entity.getAssets().size() - 1);
					UiThumbnail thumbnail = thumbnailConverter.getBeanFromEntity(lastAddedAsset.getThumbnail(),
							ResultType.FULL);
					thumbnail.setToken(securedStreamTokenUtil.getSignedAssetStreamToken(lastAddedAsset.getThumbnail()));
					bean.setAlbumThumbnail(thumbnail);
				}

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
		
		if(bean.getNewPassword() != null) {
			password = passwordEncoder.encode(bean.getNewPassword());	
		} else if (bean.getPublicAccess()) {
			password = entity.getPassword();
		} 
		
		
		albumConverter.populateEntityWithBean(entity, bean);
		
		updateAlbumProperties(entity);
		
		entity.setPassword(password);
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
	
	@Override
	@Transactional
	public UiAlbum getById(Long id) {
		return albumConverter.getBeanFromEntity(albumRepository.findById(id), ResultType.FULL);
	}

}
