package com.snapcrescent.album;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.services.BaseService;
import com.snapcrescent.common.utils.SecuredStreamTokenUtil;
import com.snapcrescent.common.utils.StringUtils;
import com.snapcrescent.common.utils.Constant.AlbumType;
import com.snapcrescent.common.utils.Constant.ResultType;
import com.snapcrescent.thumbnail.ThumbnailConverter;
import com.snapcrescent.thumbnail.UiThumbnail;
import com.snapcrescent.user.User;

@Service
public class AlbumServiceImpl extends BaseService implements AlbumService{

	@Autowired
	private AlbumRepository albumRepository;
	
	@Autowired
	private AlbumConverter albumConverter;
	
	@Autowired
	private ThumbnailConverter thumbnailConverter;
	
	@Autowired
	private SecuredStreamTokenUtil securedStreamTokenUtil;
	
	@Override
	@Transactional
	public BaseResponseBean<Long, UiAlbum> search(AlbumSearchCriteria searchCriteria) {

		BaseResponseBean<Long, UiAlbum> response = new BaseResponseBean<>();

		int count = albumRepository.count(searchCriteria);

		if (count > 0) {
			
			List<Album> entities = albumRepository.search(searchCriteria, searchCriteria.getResultType() == ResultType.OPTION);
			List<UiAlbum> beans = new ArrayList<UiAlbum>(entities.size());
			
			for (Album entity : entities) {
				UiAlbum bean = albumConverter.getBeanFromEntity(entity,searchCriteria.getResultType());
				
				if(entity.getCreatedByUserId() == coreService.getAppUser().getId()) {
					bean.setOwnedByMe(true);
				}
				
				if(entity.getUsers().size() > 1) {
					bean.setSharedWithOthers(true);
				}
				
				Asset lastAddedAsset = entity.getAssets().get(entity.getAssets().size() - 1);
				UiThumbnail thumbnail = thumbnailConverter.getBeanFromEntity(lastAddedAsset.getThumbnail(), ResultType.FULL);
				thumbnail.setToken(securedStreamTokenUtil.getSignedAssetStreamToken(lastAddedAsset.getThumbnail()));
				bean.setAlbumThumbnail(thumbnail);
				
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
		albumConverter.populateEntityWithBean(entity, bean);
		updateAlbumProperties(entity);
		albumRepository.save(entity);

	}
	
	@Override
	@Transactional
	public void createOrUpdateDefaultAlbum(User user) throws Exception {
		
		String name = StringUtils.generateDefaultAlbumName(user.getFirstName(), user.getLastName());
		Album entity = albumRepository.findDefaultAlbumByUserId(user.getId());
		
		if(entity == null) {
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
}
